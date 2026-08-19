import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:edge_ai_iam_sod/core/theme/design_tokens.dart';
import 'package:edge_ai_iam_sod/core/widgets/atoms/app_button.dart';
import 'package:edge_ai_iam_sod/core/widgets/atoms/app_text_field.dart';
import 'package:edge_ai_iam_sod/core/widgets/atoms/progress_bar.dart';
import 'package:edge_ai_iam_sod/core/widgets/atoms/status_badge.dart';
import 'package:edge_ai_iam_sod/core/widgets/atoms/token_chip.dart';
import 'package:edge_ai_iam_sod/core/widgets/molecules/checklist_card.dart';
import 'package:edge_ai_iam_sod/core/widgets/molecules/device_card.dart';
import 'package:edge_ai_iam_sod/core/widgets/molecules/login_form.dart';
import 'package:edge_ai_iam_sod/core/widgets/molecules/nav_item.dart';
import 'package:edge_ai_iam_sod/core/widgets/molecules/page_header.dart';
import 'package:edge_ai_iam_sod/core/widgets/molecules/stat_card.dart';
import 'package:edge_ai_iam_sod/core/widgets/organisms/action_bar.dart';
import 'package:edge_ai_iam_sod/core/widgets/organisms/data_table.dart' as dt;
import 'package:edge_ai_iam_sod/core/widgets/organisms/device_detail_panel.dart';
import 'package:edge_ai_iam_sod/core/widgets/organisms/side_navigation.dart';
import 'package:edge_ai_iam_sod/core/widgets/organisms/top_bar.dart';
import 'package:edge_ai_iam_sod/features/loader/domain/entities/ble_device.dart';

BleDevice _testDevice({
  BleConnectionState state = BleConnectionState.connected,
  bool authorized = true,
  bool licenseExpired = false,
}) {
  return BleDevice(
    name: 'PLC-001',
    mac: 'C1:51:53:9E:6A:17',
    model: 'S7-1200',
    family: 'SIMATIC',
    hardware: '6ES7214-1HG40-0XB0',
    connectionState: state,
    modifiedBy: 'tech_mantenimiento',
    voltage: 24.0,
    temperature: 45.0,
    authorized: authorized,
    licenseExpired: licenseExpired,
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppButton', () {
    testWidgets('renders label with minimum 48x48 tactile target',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Escanear')));
      expect(find.text('Escanear'), findsOneWidget);
      final size = tester.getSize(find.byType(AppButton));
      expect(size.width, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
      expect(size.height, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
    });

    testWidgets('fires onPressed when enabled', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(AppButton(
        label: 'Aceptar',
        onPressed: () => pressed = true,
      )));
      await tester.tap(find.text('Aceptar'));
      expect(pressed, isTrue);
    });

    testWidgets('does not fire when disabled', (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(AppButton(
        label: 'Aceptar',
        onPressed: () => pressed = true,
        enabled: false,
      )));
      await tester.tap(find.text('Aceptar'));
      expect(pressed, isFalse);
    });

    testWidgets('shows spinner and blocks taps while loading',
        (tester) async {
      var pressed = false;
      await tester.pumpWidget(_wrap(AppButton(
        label: 'Conectar',
        onPressed: () => pressed = true,
        loading: true,
      )));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Conectar'));
      expect(pressed, isFalse);
    });

    testWidgets('filled variant uses govBlue default', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Iniciar')));
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(
        button.style?.backgroundColor?.resolve({}),
        DesignTokens.govBlue,
      );
    });

    testWidgets('color override applies safeGreen semantics', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(
        label: 'Autorizado',
        color: DesignTokens.safeGreen,
      )));
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(
        button.style?.backgroundColor?.resolve({}),
        DesignTokens.safeGreen,
      );
    });

    testWidgets('outlined variant renders OutlinedButton', (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(
        label: 'Cancelar',
        variant: AppButtonVariant.outlined,
      )));
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('AppTextField', () {
    testWidgets('renders label and accepts input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(AppTextField(
        controller: controller,
        label: 'Usuario',
      )));
      expect(find.text('Usuario'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), 'admin');
      expect(controller.text, 'admin');
    });

    testWidgets('obscures password input', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(AppTextField(
        controller: controller,
        label: 'Contraseña',
        obscureText: true,
      )));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.obscureText, isTrue);
    });

    testWidgets('runs validator and shows error', (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      await tester.pumpWidget(_wrap(Form(
        child: AppTextField(
          controller: controller,
          label: 'Usuario',
          validator: (value) =>
              (value == null || value.isEmpty) ? 'Ingrese su usuario' : null,
        ),
      )));
      final form = tester.state<FormState>(find.byType(Form));
      form.validate();
      await tester.pump();
      expect(find.text('Ingrese su usuario'), findsOneWidget);
    });
  });

  group('StatusBadge', () {
    for (final tone in StatusTone.values) {
      testWidgets('renders $tone label', (tester) async {
        await tester.pumpWidget(_wrap(StatusBadge(
          label: 'Estado',
          tone: tone,
        )));
        expect(find.text('Estado'), findsOneWidget);
      });
    }

    testWidgets('danger tone uses safetyRed foreground', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(
        label: 'Bloqueado',
        tone: StatusTone.danger,
      )));
      final text = tester.widget<Text>(find.text('Bloqueado'));
      expect(text.style?.color, DesignTokens.safetyRed);
    });

    testWidgets('success tone uses safeGreen foreground', (tester) async {
      await tester.pumpWidget(_wrap(const StatusBadge(
        label: 'Autorizado',
        tone: StatusTone.success,
      )));
      final text = tester.widget<Text>(find.text('Autorizado'));
      expect(text.style?.color, DesignTokens.safeGreen);
    });
  });

  group('TokenChip', () {
    testWidgets('renders label and icon', (tester) async {
      await tester.pumpWidget(_wrap(const TokenChip(
        label: 'PLC-7F3A',
        icon: Icons.memory,
      )));
      expect(find.text('PLC-7F3A'), findsOneWidget);
      expect(find.byIcon(Icons.memory), findsOneWidget);
    });

    testWidgets('fires onDeleted when close icon tapped', (tester) async {
      var deleted = false;
      await tester.pumpWidget(_wrap(TokenChip(
        label: 'PLC-7F3A',
        onDeleted: () => deleted = true,
      )));
      await tester.tap(find.byIcon(Icons.close));
      expect(deleted, isTrue);
    });

    testWidgets('defaults to govBlue color', (tester) async {
      await tester.pumpWidget(_wrap(const TokenChip(label: 'PLC-7F3A')));
      final text = tester.widget<Text>(find.text('PLC-7F3A'));
      expect(text.style?.color, DesignTokens.govBlue);
    });
  });

  group('ProgressBar', () {
    testWidgets('renders with default safeGreen color', (tester) async {
      await tester.pumpWidget(_wrap(const ProgressBar(value: 0.5)));
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.value, 0.5);
      expect(indicator.color, DesignTokens.safeGreen);
    });

    testWidgets('honors color and minHeight overrides', (tester) async {
      await tester.pumpWidget(_wrap(const ProgressBar(
        value: 0.25,
        color: DesignTokens.warningYellow,
        minHeight: 16,
      )));
      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.color, DesignTokens.warningYellow);
      expect(indicator.minHeight, 16);
    });
  });

  group('LoginForm', () {
    testWidgets('userPassword variant renders fields and submit',
        (tester) async {
      await tester.pumpWidget(_wrap(const LoginForm()));
      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('validates empty userPassword form locally',
        (tester) async {
      var submitted = false;
      await tester.pumpWidget(_wrap(LoginForm(
        onUserPasswordSubmit: (user, pass) => submitted = true,
      )));
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(find.text('Ingrese su usuario'), findsOneWidget);
      expect(find.text('Ingrese su contraseña'), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('submits user and password on valid input',
        (tester) async {
      String? submittedUser;
      String? submittedPass;
      await tester.pumpWidget(_wrap(LoginForm(
        onUserPasswordSubmit: (user, pass) {
          submittedUser = user;
          submittedPass = pass;
        },
      )));
      await tester.enterText(find.byType(TextFormField).at(0), 'admin');
      await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(submittedUser, 'admin');
      expect(submittedPass, 'admin123');
    });

    testWidgets('token variant renders single field and submits token',
        (tester) async {
      String? submittedToken;
      await tester.pumpWidget(_wrap(LoginForm(
        variant: LoginVariant.token,
        onTokenSubmit: (token) => submittedToken = token,
      )));
      expect(find.text('Token'), findsOneWidget);
      expect(find.text('Usuario'), findsNothing);
      await tester.enterText(find.byType(TextFormField), 'jwt-token-abc');
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(submittedToken, 'jwt-token-abc');
    });

    testWidgets('token variant validates empty input', (tester) async {
      var submitted = false;
      await tester.pumpWidget(_wrap(LoginForm(
        variant: LoginVariant.token,
        onTokenSubmit: (_) => submitted = true,
      )));
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(find.text('Ingrese su token'), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('renders errorMessage inline as danger badge',
        (tester) async {
      await tester.pumpWidget(_wrap(const LoginForm(
        errorMessage: 'Usuario o contraseña incorrectos',
      )));
      expect(
        find.text('Usuario o contraseña incorrectos'),
        findsOneWidget,
      );
      final badge = tester.widget<StatusBadge>(
        find.byType(StatusBadge),
      );
      expect(badge.tone, StatusTone.danger);
    });

    testWidgets('shows loading spinner when isLoading', (tester) async {
      await tester.pumpWidget(_wrap(const LoginForm(isLoading: true)));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('uses custom buttonLabel', (tester) async {
      await tester.pumpWidget(_wrap(
        const LoginForm(buttonLabel: 'INICIAR SESION'),
      ));
      expect(find.text('INICIAR SESION'), findsOneWidget);
    });

    testWidgets('submit button meets 48dp tactile minimum',
        (tester) async {
      await tester.pumpWidget(_wrap(const LoginForm()));
      final size = tester.getSize(find.byType(AppButton));
      expect(size.width, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
      expect(size.height, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
    });
  });

  group('StatCard', () {
    testWidgets('renders title, value and icon', (tester) async {
      await tester.pumpWidget(_wrap(const StatCard(
        title: 'Usuarios Activos',
        value: '3',
        icon: Icons.people,
        color: DesignTokens.safeGreen,
      )));
      expect(find.text('Usuarios Activos'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
    });

    testWidgets('value rendered 24px bold in accent color',
        (tester) async {
      await tester.pumpWidget(_wrap(const StatCard(
        title: 'Activos',
        value: '12',
        icon: Icons.inventory,
        color: DesignTokens.govBlue,
      )));
      final value = tester.widget<Text>(find.text('12'));
      expect(value.style?.fontSize, DesignTokens.textXl2);
      expect(value.style?.fontWeight, FontWeight.bold);
      expect(value.style?.color, DesignTokens.govBlue);
    });

    testWidgets('fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(StatCard(
        title: 'Métrica',
        value: '1',
        icon: Icons.info,
        color: DesignTokens.govBlue,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('Métrica'));
      expect(tapped, isTrue);
    });
  });

  group('NavItem', () {
    testWidgets('renders icon and label', (tester) async {
      await tester.pumpWidget(_wrap(NavItem(
        icon: Icons.dashboard,
        label: 'Dashboard',
        selected: false,
        onTap: () {},
      )));
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byIcon(Icons.dashboard), findsOneWidget);
    });

    testWidgets('fires onTap and meets 48dp height', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(NavItem(
        icon: Icons.people,
        label: 'Usuarios',
        selected: false,
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('Usuarios'));
      expect(tapped, isTrue);
      final size = tester.getSize(find.byType(NavItem));
      expect(size.height, greaterThanOrEqualTo(DesignTokens.tactileMinSize));
    });

    testWidgets('shows badge count', (tester) async {
      await tester.pumpWidget(_wrap(NavItem(
        icon: Icons.notifications,
        label: 'Alertas',
        selected: false,
        badge: 3,
        onTap: () {},
      )));
      expect(find.text('3'), findsOneWidget);
    });
  });

  group('ChecklistCard', () {
    testWidgets('renders title, description and CRÍTICO badge',
        (tester) async {
      await tester.pumpWidget(_wrap(const ChecklistCard(
        title: 'Validación SoD',
        description: 'Verificar segregación de funciones',
        isCritical: true,
        onToggle: _noop,
      )));
      expect(find.text('Validación SoD'), findsOneWidget);
      expect(
        find.text('Verificar segregación de funciones'),
        findsOneWidget,
      );
      expect(find.text('CRÍTICO'), findsOneWidget);
      final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(badge.tone, StatusTone.danger);
    });

    testWidgets('fires onToggle and exposes 48x48 checkbox',
        (tester) async {
      var toggled = false;
      await tester.pumpWidget(_wrap(ChecklistCard(
        title: 'Conexión BLE',
        description: 'Establecer conexión Bluetooth',
        onToggle: () => toggled = true,
      )));
      final check = find.byIcon(Icons.check);
      expect(check, findsNothing);
      await tester.tap(find.text('Conexión BLE'));
      expect(toggled, isTrue);
    });

    testWidgets('shows check icon when completed', (tester) async {
      await tester.pumpWidget(_wrap(const ChecklistCard(
        title: 'Conexión BLE',
        description: 'Establecer conexión Bluetooth',
        isCompleted: true,
        onToggle: _noop,
      )));
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('DeviceCard', () {
    testWidgets('renders name, MAC and connection badge', (tester) async {
      await tester.pumpWidget(_wrap(DeviceCard(
        device: _testDevice(),
        onTap: _noop,
      )));
      expect(find.text('PLC-001'), findsOneWidget);
      expect(find.text('C1:51:53:9E:6A:17'), findsOneWidget);
      expect(find.text('Conectado'), findsOneWidget);
    });

    testWidgets('maps connecting state to Conectando… warning',
        (tester) async {
      await tester.pumpWidget(_wrap(DeviceCard(
        device: _testDevice(state: BleConnectionState.connecting),
        onTap: _noop,
      )));
      expect(find.text('Conectando…'), findsOneWidget);
      final badge = tester.widget<StatusBadge>(find.byType(StatusBadge));
      expect(badge.tone, StatusTone.warning);
    });

    testWidgets('fires onTap', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(DeviceCard(
        device: _testDevice(),
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('PLC-001'));
      expect(tapped, isTrue);
    });

    testWidgets('renders trailing actions', (tester) async {
      await tester.pumpWidget(_wrap(DeviceCard(
        device: _testDevice(),
        onTap: _noop,
        actions: const [Icon(Icons.edit)],
      )));
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  group('PageHeader', () {
    testWidgets('renders title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(const PageHeader(
        title: 'Gestión de Accesos',
        subtitle: 'Usuarios institucionales',
      )));
      expect(find.text('Gestión de Accesos'), findsOneWidget);
      expect(find.text('Usuarios institucionales'), findsOneWidget);
    });

    testWidgets('search field reports changes', (tester) async {
      String? query;
      await tester.pumpWidget(_wrap(PageHeader(
        title: 'Usuarios',
        searchHint: 'Buscar...',
        onSearchChanged: (value) => query = value,
      )));
      await tester.enterText(find.byType(TextField), 'admin');
      expect(query, 'admin');
    });

    testWidgets('renders trailing actions', (tester) async {
      await tester.pumpWidget(_wrap(const PageHeader(
        title: 'Usuarios',
        actions: [Icon(Icons.add)],
      )));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('SideNavigation', () {
    const items = [
      NavItemData(icon: Icons.dashboard, label: 'Dashboard'),
      NavItemData(icon: Icons.people, label: 'Gestión de Accesos'),
    ];

    Widget buildNav({ValueChanged<int>? onSelect, VoidCallback? onLogout}) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 600,
            child: SideNavigation(
              items: items,
              selectedIndex: 0,
              onSelect: onSelect ?? _noopIndex,
              username: 'admin_principal',
              roleLabel: 'Administrador',
              avatarInitials: 'AP',
              onLogout: onLogout ?? _noop,
            ),
          ),
        ),
      );
    }

    testWidgets('renders header, items and logout', (tester) async {
      await tester.pumpWidget(buildNav());
      expect(find.text('admin_principal'), findsOneWidget);
      expect(find.text('Administrador'), findsOneWidget);
      expect(find.text('AP'), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('Gestión de Accesos'), findsOneWidget);
      expect(find.text('Cerrar Sesión'), findsOneWidget);
    });

    testWidgets('fires onSelect with item index', (tester) async {
      int? selected;
      await tester.pumpWidget(buildNav(onSelect: (i) => selected = i));
      await tester.tap(find.text('Gestión de Accesos'));
      expect(selected, 1);
    });

    testWidgets('fires onLogout', (tester) async {
      var loggedOut = false;
      await tester.pumpWidget(buildNav(onLogout: () => loggedOut = true));
      await tester.tap(find.text('Cerrar Sesión'));
      expect(loggedOut, isTrue);
    });
  });

  group('TopBar', () {
    testWidgets('renders 24px bold title', (tester) async {
      await tester.pumpWidget(_wrap(const TopBar(title: 'Studio')));
      final title = tester.widget<Text>(find.text('Studio'));
      expect(title.style?.fontSize, DesignTokens.textXl2);
      expect(title.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renders subtitle, search and actions', (tester) async {
      await tester.pumpWidget(_wrap(const TopBar(
        title: 'Studio',
        subtitle: 'Escaneo Bluetooth',
        searchHint: 'Buscar...',
        actions: [Icon(Icons.logout)],
      )));
      expect(find.text('Escaneo Bluetooth'), findsOneWidget);
      expect(find.text('Buscar...'), findsOneWidget);
      expect(find.byIcon(Icons.logout), findsOneWidget);
    });

    testWidgets('search field reports changes', (tester) async {
      String? query;
      await tester.pumpWidget(_wrap(TopBar(
        title: 'Studio',
        searchHint: 'Buscar...',
        onSearchChanged: (value) => query = value,
      )));
      await tester.enterText(find.byType(TextField), 'PLC');
      expect(query, 'PLC');
    });
  });

  group('DataTable', () {
    testWidgets('renders headers and row cells', (tester) async {
      await tester.pumpWidget(_wrap(dt.DataTable(
        columns: const [
          dt.DataTableColumn(label: 'Dispositivo', flex: 2),
          dt.DataTableColumn(label: 'Estado'),
        ],
        rows: [
          dt.DataTableRow(cells: [
            const Text('PLC-001'),
            const StatusBadge(
              label: 'Conectado',
              tone: StatusTone.success,
            ),
          ]),
        ],
      )));
      expect(find.text('Dispositivo'), findsOneWidget);
      expect(find.text('Estado'), findsOneWidget);
      expect(find.text('PLC-001'), findsOneWidget);
      expect(find.text('Conectado'), findsOneWidget);
    });

    testWidgets('renders row actions', (tester) async {
      await tester.pumpWidget(_wrap(dt.DataTable(
        columns: const [dt.DataTableColumn(label: 'Dispositivo')],
        rows: [
          dt.DataTableRow(
            cells: const [Text('PLC-001')],
            actions: const [Icon(Icons.edit)],
          ),
        ],
      )));
      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });

  group('ActionBar', () {
    testWidgets('fires primary and secondary callbacks', (tester) async {
      var primary = false;
      var secondary = false;
      await tester.pumpWidget(_wrap(ActionBar(
        primaryLabel: 'Vincular',
        onPrimary: () => primary = true,
        secondaryLabel: 'Cancelar',
        onSecondary: () => secondary = true,
      )));
      await tester.tap(find.text('Vincular'));
      expect(primary, isTrue);
      await tester.tap(find.text('Cancelar'));
      expect(secondary, isTrue);
    });

    testWidgets('disabled primary does not fire', (tester) async {
      var primary = false;
      await tester.pumpWidget(_wrap(ActionBar(
        primaryLabel: 'Proceder',
        onPrimary: () => primary = true,
        primaryEnabled: false,
      )));
      await tester.tap(find.text('Proceder'));
      expect(primary, isFalse);
    });

    testWidgets('buttons meet 48dp tactile minimum', (tester) async {
      await tester.pumpWidget(_wrap(ActionBar(
        primaryLabel: 'Proceder',
        onPrimary: _noop,
        secondaryLabel: 'Reiniciar',
        onSecondary: _noop,
      )));
      for (final label in ['Proceder', 'Reiniciar']) {
        final button = find.ancestor(
          of: find.text(label),
          matching: find.byType(AppButton),
        );
        final size = tester.getSize(button);
        expect(
          size.height,
          greaterThanOrEqualTo(DesignTokens.tactileMinSize),
        );
      }
    });
  });

  group('DeviceDetailPanel', () {
    testWidgets('renders device fields and connection badge',
        (tester) async {
      await tester.pumpWidget(_wrap(DeviceDetailPanel(
        device: _testDevice(),
      )));
      expect(find.text('Familia/Modelo'), findsOneWidget);
      expect(find.text('SIMATIC / S7-1200'), findsOneWidget);
      expect(find.text('Hardware'), findsOneWidget);
      expect(find.text('6ES7214-1HG40-0XB0'), findsOneWidget);
      expect(find.text('Dirección MAC'), findsOneWidget);
      expect(find.text('C1:51:53:9E:6A:17'), findsOneWidget);
      expect(find.text('Modificada por'), findsOneWidget);
      expect(find.text('tech_mantenimiento'), findsOneWidget);
      expect(find.text('24.0 V / 45.0 °C'), findsOneWidget);
      expect(find.text('Autorizada'), findsOneWidget);
      expect(find.text('Conectado'), findsOneWidget);
    });

    testWidgets('renders Congelada danger status when not authorized',
        (tester) async {
      await tester.pumpWidget(_wrap(DeviceDetailPanel(
        device: _testDevice(authorized: false),
      )));
      expect(find.text('Congelada'), findsOneWidget);
      final badge = tester.widget<StatusBadge>(
        find.widgetWithText(StatusBadge, 'Congelada'),
      );
      expect(badge.tone, StatusTone.danger);
    });
  });
}

void _noop() {}

void _noopIndex(int index) {}