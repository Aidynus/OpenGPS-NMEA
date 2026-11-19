// Simple runtime localisation (English / Russian) for JetourGPS.
//
// Screens import this file together with
//   import 'package:flutter/material.dart' hide Text;
// so that every `Text('English string')` is translated automatically.
// Strings that are not widgets (tooltips, labelText, ...) use [Tr.s].
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart' hide Text;
import 'package:flutter/widgets.dart' as m show Text;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Selected UI language: 'system' | 'en' | 'ru'. Mirrors [Tr.mode] so that
/// screens can rebuild (tooltips etc.) when the language changes.
final languageProvider = StateProvider<String>((ref) => Tr.mode.value);

class Tr {
  Tr._();

  static const _prefsKey = 'app_language';

  /// 'system' | 'en' | 'ru'
  static final ValueNotifier<String> mode = ValueNotifier<String>('system');

  static bool get isRu {
    final v = mode.value;
    if (v == 'ru') return true;
    if (v == 'en') return false;
    return PlatformDispatcher.instance.locale.languageCode == 'ru';
  }

  /// Loads the saved language. Call once before runApp.
  static Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final v = p.getString(_prefsKey);
      if (v != null && (v == 'ru' || v == 'en' || v == 'system')) {
        mode.value = v;
      }
    } catch (_) {
      // Keep the default (system).
    }
  }

  static Future<void> setMode(String v) async {
    mode.value = v;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_prefsKey, v);
    } catch (_) {
      // Not critical: the choice just will not persist.
    }
  }

  /// Translates [key] (an English UI string) into the current language.
  static String s(String key) {
    if (!isRu || key.isEmpty) return key;
    final exact = _ru[key];
    if (exact != null) return exact;
    // Raw NMEA / TAIP sentences and similar: never translate.
    final c = key.codeUnitAt(0);
    if (c == 0x24 /* $ */ || c == 0x3E /* > */) return key;
    var out = key;
    for (final r in _rules) {
      out = out.replaceAllMapped(r.$1, (mm) => _expand(r.$2, mm));
    }
    return out;
  }

  static String? n(String? key) => key == null ? null : s(key);

  static String _expand(String tpl, Match mm) => tpl.replaceAllMapped(
        RegExp(r'\$(\d)'),
        (t) => mm.group(int.parse(t.group(1)!)) ?? '',
      );
}

/// Drop-in replacement for the material [Text] that translates its string.
class Text extends StatelessWidget {
  const Text(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  final String data;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: Tr.mode,
      builder: (context, _, __) => m.Text(
        Tr.s(data),
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        softWrap: softWrap,
      ),
    );
  }
}

// ── Russian translations (exact match) ───────────────────────────────────────

const Map<String, String> _ru = {
  // Main screen
  'Dismiss': 'Закрыть',
  'Sentence log': 'Журнал сообщений',
  'Settings': 'Настройки',
  'Off': 'Выкл.',
  'Connecting…': 'Подключение…',
  'Active': 'Активно',
  'Reconnecting…': 'Переподключение…',
  'Error': 'Ошибка',
  'Status': 'Состояние',
  'Tx': 'Отправлено',
  'Rx': 'Получено',
  'Clients': 'Клиенты',
  'Last Tx': 'Последняя отправка',
  'WiFi IP': 'IP Wi-Fi',
  'Cellular IP': 'IP сотовой сети',
  'Hotspot IP': 'IP точки доступа',
  'Network info unavailable': 'Сведения о сети недоступны',
  'Port': 'Порт',
  'advertising': 'ожидает подключения',
  'Position': 'Положение',
  'No Fix': 'Нет сигнала GPS',
  'No fix': 'Нет сигнала',
  'Good': 'Хорошая',
  'Moderate': 'Средняя',
  'Low': 'Низкая',
  'Alt': 'Высота',
  'Course': 'Курс',
  'Speed': 'Скорость',
  'Connected': 'Подключено',
  'Waiting for connection…': 'Ожидание подключения…',
  'Connected devices': 'Подключённые устройства',
  'GPS to the car via Bluetooth LE': 'GPS в автомобиль по Bluetooth LE',
  'Author: Маратов Айдын': 'Автор: Маратов Айдын',
  'Back': 'Назад',
  // Bluetooth errors
  'Bluetooth is turned off or unavailable. Turn on Bluetooth and allow access in iPhone Settings.':
      'Bluetooth выключен или недоступен. Включите Bluetooth и разрешите доступ в Настройках iPhone.',
  'Bluetooth transmission is supported on iPhone only.':
      'Передача по Bluetooth работает только на iPhone.',
  'Could not start Bluetooth transmission.':
      'Не удалось запустить передачу по Bluetooth.',
  // Units and compass points
  'm': 'м',
  'kn': 'уз',
  'km/h': 'км/ч',
  'mph': 'миль/ч',
  'm/s': 'м/с',
  'N': 'С',
  'NNE': 'ССВ',
  'NE': 'СВ',
  'ENE': 'ВСВ',
  'E': 'В',
  'ESE': 'ВЮВ',
  'SE': 'ЮВ',
  'SSE': 'ЮЮВ',
  'S': 'Ю',
  'SSW': 'ЮЮЗ',
  'SW': 'ЮЗ',
  'WSW': 'ЗЮЗ',
  'W': 'З',
  'WNW': 'ЗСЗ',
  'NW': 'СЗ',
  'NNW': 'ССЗ',
  // Settings
  'Language': 'Язык',
  'System default': 'Как в системе',
  'Connection profiles': 'Профили подключения',
  'Reset to defaults': 'Сбросить настройки',
  'Reset all settings?': 'Сбросить все настройки?',
  'All settings will be returned to their defaults. This cannot be undone.':
      'Все настройки будут возвращены к значениям по умолчанию. Это действие нельзя отменить.',
  'Cancel': 'Отмена',
  'Reset': 'Сбросить',
  'General': 'Общие',
  'GPS Accuracy': 'Точность GPS',
  'Very Best': 'Максимальная',
  'Pretty Good': 'Высокая',
  'Lazy': 'Низкая (экономия)',
  'Update Frequency': 'Частота обновления',
  'No Delay': 'Без задержки',
  '1 second': '1 секунда',
  '5 seconds': '5 секунд',
  '30 seconds': '30 секунд',
  '1 minute': '1 минута',
  '5 minutes': '5 минут',
  '30 minutes': '30 минут',
  '1 hour': '1 час',
  'Protocol': 'Протокол',
  'Speed Unit': 'Единица скорости',
  'Knots': 'Узлы',
  'Operate in Background': 'Работа в фоне',
  'Bundle into 1 Transmission': 'Объединять в одну отправку',
  'High Contrast': 'Высокий контраст',
  'True North (not Magnetic)': 'Истинный север (не магнитный)',
  'Operate When Terminated': 'Работа после закрытия приложения',
  'Display Decimal Minutes': 'Десятичные минуты',
  'Disable When Static': 'Отключать при неподвижности',
  'Static Threshold': 'Порог неподвижности',
  'NMEA Messages': 'Сообщения NMEA',
  'GGA  (Fix data)': 'GGA  (Данные фиксации)',
  'GLL  (Lat/Lon)': 'GLL  (Широта/Долгота)',
  'GSA  (DOP + Sats)': 'GSA  (DOP и спутники)',
  'HDG  (Mag heading)': 'HDG  (Магнитный курс)',
  'HDM  (Mag heading simple)': 'HDM  (Магнитный курс, упрощённый)',
  'HDT  (True heading)': 'HDT  (Истинный курс)',
  'RMC  (Recommended minimum)': 'RMC  (Рекомендуемый минимум)',
  'VTG  (Speed/Track)': 'VTG  (Скорость/Путь)',
  'ZDA  (Date/Time)': 'ZDA  (Дата/Время)',
  'PASHR  (Ashtech attitude)': 'PASHR  (Ориентация Ashtech)',
  'GPTXT  (Custom text)': 'GPTXT  (Свой текст)',
  'GPTXT Text': 'Текст GPTXT',
  'TAIP Messages': 'Сообщения TAIP',
  'PV  (Position/Velocity)': 'PV  (Положение/Скорость)',
  'AL  (Altitude)': 'AL  (Высота)',
  'Device ID': 'ID устройства',
  'Connection': 'Подключение',
  'Socket (TCP Server)': 'Сокет (TCP-сервер)',
  'TCP Client': 'TCP-клиент',
  'Socket Port': 'Порт сокета',
  'Target IP': 'IP получателя',
  'Target Port': 'Порт получателя',
  'Multicast Group': 'Группа multicast',
  'WebSocket URL': 'Адрес WebSocket',
  'WebSocket Port': 'Порт WebSocket',
  'Network Interface': 'Сетевой интерфейс',
  'WiFi': 'Wi-Fi',
  'Cellular': 'Сотовая сеть',
  'Hotspot': 'Точка доступа',
  'BLE Enabled': 'BLE включён',
  'BLE Device Name': 'Имя BLE-устройства',
  'Security': 'Безопасность',
  'Password lock removed': 'Парольная блокировка снята',
  'Password lock set': 'Парольная блокировка установлена',
  'Settings locked': 'Настройки заблокированы',
  'Settings unlocked': 'Настройки не заблокированы',
  'Remove Lock': 'Снять блокировку',
  'Change password': 'Сменить пароль',
  'Set password': 'Задать пароль',
  'Enter new password': 'Введите новый пароль',
  'Enter password': 'Введите пароль',
  'Set': 'Задать',
  // Profiles
  'Connection Profiles': 'Профили подключения',
  'New profile': 'Новый профиль',
  'No saved profiles.\nTap + to create one.':
      'Нет сохранённых профилей.\nНажмите +, чтобы создать.',
  'Create profile': 'Создать профиль',
  'Delete profile?': 'Удалить профиль?',
  'Delete': 'Удалить',
  'Edit': 'Изменить',
  'Apply': 'Применить',
  'Socket': 'Сокет',
  'Multicast': 'Multicast',
  'Broadcast': 'Broadcast',
  'Unknown': 'Неизвестно',
  'New Profile': 'Новый профиль',
  'Edit Profile': 'Изменить профиль',
  'Profile Name': 'Название профиля',
  'Required': 'Обязательно',
  'Connection Method': 'Способ подключения',
  'Target IP Address': 'IP-адрес получателя',
  'Enter a valid port (1–65535)': 'Введите корректный порт (1–65535)',
  'Save': 'Сохранить',
  // Sentence log
  'Sentence Log': 'Журнал сообщений',
  'Copy all': 'Копировать всё',
  'Share': 'Поделиться',
  'Clear': 'Очистить',
  'No sentences yet.\nStart transmission to see output here.':
      'Сообщений пока нет.\nЗапустите передачу, чтобы увидеть их здесь.',
  'Copied to clipboard': 'Скопировано в буфер обмена',
  'Sentence copied': 'Сообщение скопировано',
  // Lock screen
  'Enter the password': 'Введите пароль',
  'Incorrect password': 'Неверный пароль',
  'Settings Locked': 'Настройки заблокированы',
  'Enter the password to access settings.':
      'Введите пароль для доступа к настройкам.',
  'Password': 'Пароль',
  'Unlock': 'Разблокировать',
  // Location errors
  'Location permission denied. Grant access in Settings → JetourGPS → Location.':
      'Доступ к геопозиции запрещён. Разрешите его в Настройки → JetourGPS → Геолокация.',
  'Location services are disabled. Enable in device Settings → Privacy → Location Services.':
      'Службы геолокации отключены. Включите их в Настройки → Конфиденциальность → Службы геолокации.',
};

// ── Russian translations (patterns with $1, $2 ... substitutions) ───────────

final List<(RegExp, String)> _rules = [
  (RegExp(r'^AppError\((.*?)\): '), r'Ошибка ($1): '),
  (RegExp(r' — caused by: '), ' — причина: '),
  (
    RegExp(
        r'Port (\d+) is already in use\. Change the port in Settings → Network\.'),
    r'Порт $1 уже занят. Измените порт в Настройки → Сеть.'
  ),
  (
    RegExp(
        r'Location permission permanently denied\. Please enable it in app Settings\.'),
    'Доступ к геопозиции запрещён навсегда. Включите его в настройках приложения.'
  ),
  (RegExp(r'Location permission denied'), 'Доступ к геопозиции запрещён'),
  (
    RegExp(r'Location services are unavailable'),
    'Службы геолокации недоступны'
  ),
  (RegExp(r'Network is unavailable'), 'Сеть недоступна'),
  (RegExp(r'^Bluetooth error: '), 'Ошибка Bluetooth: '),
  (RegExp(r'Bluetooth is unavailable'), 'Bluetooth недоступен'),
  (
    RegExp(r'"(.*?)" is not a valid IP address\.?'),
    r'«$1» — неверный IP-адрес.'
  ),
  (
    RegExp(r'(\d+) is not a valid port number \(1–65535\)\.'),
    r'$1 — неверный номер порта (1–65535).'
  ),
  (RegExp(r'IP address cannot be empty'), 'IP-адрес не может быть пустым'),
  (RegExp(r'Port cannot be empty'), 'Порт не может быть пустым'),
  (
    RegExp(r'Port must be a number between 1 and 65535'),
    'Порт — число от 1 до 65535'
  ),
  (
    RegExp(r'Multicast address cannot be empty'),
    'Адрес multicast не может быть пустым'
  ),
  (
    RegExp(
        r'"(.*?)" is not a multicast address \(224\.x\.x\.x – 239\.x\.x\.x\)'),
    r'«$1» — не multicast-адрес (224.x.x.x – 239.x.x.x)'
  ),
  (
    RegExp(r'URL must start with ws:// or wss://'),
    'Адрес должен начинаться с ws:// или wss://'
  ),
  (RegExp(r'"(.*?)" is not a valid URL'), r'«$1» — неверный адрес URL'),
  (RegExp(r'Device ID cannot be empty'), 'ID устройства не может быть пустым'),
  (
    RegExp(r'Device ID must be 8 characters or fewer'),
    'ID устройства — не более 8 символов'
  ),
  (RegExp(r'Threshold cannot be empty'), 'Порог не может быть пустым'),
  (
    RegExp(r'Threshold must be a positive number'),
    'Порог должен быть положительным числом'
  ),
  (
    RegExp(r'^Delete "(.*)"\? This cannot be undone\.$'),
    r'Удалить «$1»? Это действие нельзя отменить.'
  ),
];
