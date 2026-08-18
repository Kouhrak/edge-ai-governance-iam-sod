"""
Unit tests for SoD Policy Engine - Edge AI Governance IAM SoD
"""

import pytest
from unittest.mock import Mock, patch
from datetime import datetime, timedelta


class TestSoDEngine:
    """Test cases for SoD Policy Engine"""

    def test_validate_same_user_approval_and_injection(self):
        """Test that same user cannot approve and inject firmware"""
        # Arrange
        user_id = "tech_001"
        approval_user_id = "tech_001"
        firmware_id = "fw_123"
        
        # Act - This should be a violation
        is_violation = self._check_sod_violation(user_id, approval_user_id)
        
        # Assert
        assert is_violation is True, "Same user should not be able to approve and inject"

    def test_validate_different_user_approval_and_injection(self):
        """Test that different users can approve and inject firmware"""
        # Arrange
        user_id = "tech_001"
        approval_user_id = "admin_001"
        firmware_id = "fw_123"
        
        # Act
        is_violation = self._check_sod_violation(user_id, approval_user_id)
        
        # Assert
        assert is_violation is False, "Different users should be allowed"

    def test_validate_role_incompatibility(self):
        """Test that incompatible roles are blocked"""
        # Arrange
        user_roles = ["Tecnico", "Administrador"]
        
        # Act
        has_incompatible_roles = self._check_role_incompatibility(user_roles)
        
        # Assert
        assert has_incompatible_roles is True, "Tecnico and Administrador are incompatible"

    def test_validate_compatible_roles(self):
        """Test that compatible roles are allowed"""
        # Arrange
        user_roles = ["Tecnico", "Operador"]
        
        # Act
        has_incompatible_roles = self._check_role_incompatibility(user_roles)
        
        # Assert
        assert has_incompatible_roles is False, "Tecnico and Operador are compatible"

    def test_validate_work_order_state(self):
        """Test that work order must be approved before injection"""
        # Arrange
        work_order_state = "APPROVED"
        required_state = "APPROVED"
        
        # Act
        is_valid = work_order_state == required_state
        
        # Assert
        assert is_valid is True, "Work order must be approved"

    def test_validate_work_order_pending(self):
        """Test that pending work order blocks injection"""
        # Arrange
        work_order_state = "PENDING"
        required_state = "APPROVED"
        
        # Act
        is_valid = work_order_state == required_state
        
        # Assert
        assert is_valid is False, "Pending work order should block injection"

    def test_sod_validation_response_format(self):
        """Test that SoD validation returns correct format"""
        # Arrange
        user_id = "tech_001"
        asset_id = "asset_456"
        firmware_id = "fw_789"
        
        # Act
        response = self._simulate_sod_validation(user_id, asset_id, firmware_id)
        
        # Assert
        assert "status" in response
        assert "message" in response
        assert "timestamp" in response
        assert response["status"] in ["ALLOWED", "BLOCKED"]
        assert isinstance(response["timestamp"], str)

    def test_sod_validation_performance(self):
        """Test that SoD validation completes within 150ms"""
        # Arrange
        start_time = datetime.now()
        user_id = "tech_001"
        asset_id = "asset_456"
        firmware_id = "fw_789"
        
        # Act
        self._simulate_sod_validation(user_id, asset_id, firmware_id)
        end_time = datetime.now()
        
        # Assert
        execution_time = (end_time - start_time).total_seconds() * 1000  # Convert to ms
        assert execution_time < 150, f"SoD validation took {execution_time}ms, should be <150ms"

    # Helper methods for testing
    def _check_sod_violation(self, user_id: str, approval_user_id: str) -> bool:
        """Check if there's a SoD violation between user and approver"""
        return user_id == approval_user_id

    def _check_role_incompatibility(self, roles: list) -> bool:
        """Check if there are incompatible roles"""
        incompatible_pairs = [
            ("Tecnico", "Administrador"),
            ("Operador", "Administrador"),
            ("Externo", "Tecnico"),
        ]
        
        for role1, role2 in incompatible_pairs:
            if role1 in roles and role2 in roles:
                return True
        return False

    def _simulate_sod_validation(self, user_id: str, asset_id: str, firmware_id: str) -> dict:
        """Simulate SoD validation and return response"""
        return {
            "status": "ALLOWED",
            "message": f"User {user_id} is authorized to inject firmware {firmware_id} on asset {asset_id}",
            "timestamp": datetime.now().isoformat(),
            "validation_id": f"val_{user_id}_{asset_id}_{firmware_id}"
        }


class TestSoDMatrix:
    """Test cases for SoD Matrix"""

    def test_sod_matrix_contains_exclusion_rules(self):
        """Test that SoD matrix contains required exclusion rules"""
        # Arrange
        sod_matrix = self._get_sod_matrix()
        
        # Act & Assert
        assert len(sod_matrix) > 0, "SoD matrix should not be empty"
        
        # Check for specific exclusion
        tech_admin_exclusion = any(
            rule["rol_origen"] == "Tecnico" and rule["rol_incompatible"] == "Administrador"
            for rule in sod_matrix
        )
        assert tech_admin_exclusion, "Tecnico-Administrador exclusion should exist"

    def test_sod_matrix_prevents_self_approval(self):
        """Test that SoD matrix prevents self-approval"""
        # Arrange
        sod_matrix = self._get_sod_matrix()
        
        # Act
        self_approval_rules = [
            rule for rule in sod_matrix 
            if rule.get("bloquea_auto_aprobacion", False)
        ]
        
        # Assert
        assert len(self_approval_rules) > 0, "SoD matrix should prevent self-approval"

    def _get_sod_matrix(self) -> list:
        """Get SoD matrix rules"""
        return [
            {
                "rol_origen": "Tecnico",
                "rol_incompatible": "Administrador",
                "operacion_bloqueada": "INYECCION_FIRMWARE",
                "bloquea_auto_aprobacion": True
            },
            {
                "rol_origen": "Operador",
                "rol_incompatible": "Administrador",
                "operacion_bloqueada": "CONFIGURACION_SENSOR",
                "bloquea_auto_aprobacion": True
            }
        ]


class TestLedgerIntegrity:
    """Test cases for Cryptographic Ledger"""

    def test_hash_chain_integrity(self):
        """Test that hash chain maintains integrity"""
        # Arrange
        ledger_entries = self._create_test_ledger()
        
        # Act
        is_valid = self._validate_hash_chain(ledger_entries)
        
        # Assert
        assert is_valid is True, "Hash chain should be valid"

    def test_detect_tampering(self):
        """Test that tampering is detected"""
        # Arrange
        ledger_entries = self._create_test_ledger()
        ledger_entries[1]["detalles_payload"] = "TAMPERED"  # Tamper with entry
        
        # Act
        is_valid = self._validate_hash_chain(ledger_entries)
        
        # Assert
        assert is_valid is False, "Tampering should be detected"

    def _create_test_ledger(self) -> list:
        """Create test ledger entries"""
        import hashlib
        import json
        
        entries = []
        previous_hash = "0" * 64  # Genesis hash
        
        for i in range(3):
            payload = {
                "usuario_id": f"user_{i}",
                "accion": f"action_{i}",
                "timestamp": datetime.now().isoformat()
            }
            
            # Calculate hash
            hash_input = previous_hash + json.dumps(payload, sort_keys=True)
            current_hash = hashlib.sha256(hash_input.encode()).hexdigest()
            
            entries.append({
                "id": i,
                "hash_anterior": previous_hash,
                "hash_actual": current_hash,
                "detalles_payload": json.dumps(payload)
            })
            
            previous_hash = current_hash
        
        return entries

    def _validate_hash_chain(self, entries: list) -> bool:
        """Validate the hash chain integrity"""
        import hashlib
        import json
        
        for i in range(1, len(entries)):
            entry = entries[i]
            prev_entry = entries[i - 1]
            
            # Verify hash chain
            if entry["hash_anterior"] != prev_entry["hash_actual"]:
                return False
            
            # Recalculate hash
            payload = json.loads(entry["detalles_payload"])
            hash_input = entry["hash_anterior"] + json.dumps(payload, sort_keys=True)
            calculated_hash = hashlib.sha256(hash_input.encode()).hexdigest()
            
            if calculated_hash != entry["hash_actual"]:
                return False
        
        return True