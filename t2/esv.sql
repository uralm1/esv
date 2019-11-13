-- phpMyAdmin SQL Dump
-- version 4.7.2
-- https://www.phpmyadmin.net/
--
-- Хост: beko
-- Время создания: Май 13 2019 г., 16:33
-- Версия сервера: 10.1.26-MariaDB-0+deb9u1
-- Версия PHP: 7.1.20-1+ubuntu14.04.1+deb.sury.org+1

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данных: `esv`
--

-- --------------------------------------------------------

--
-- Структура таблицы `changelog`
--

CREATE TABLE `changelog` (
  `ver_major` int(11) NOT NULL,
  `ver_minor` int(11) NOT NULL,
  `date` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `changelog` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `changelog`
--

INSERT INTO `changelog` (`ver_major`, `ver_minor`, `date`, `changelog`) VALUES
(0, 1, '2019-01-21 00:00:00', 'Созданы метрики по отключениям.<br>\r\nСинхронизация данных по отключениям (аварийным и плановым).<br>\r\nУчёт версий и перечня изменений программ.'),
(0, 2, '2019-01-23 00:00:00', 'Плановые и внеплановые отключения добавлены в отчеты и форму диспетчера ПЛК.<br>\r\nОбработка типов и ошибок при записи метрик.<br>\r\nУлучшения и оптимизации.'),
(0, 3, '2019-01-25 00:00:00', 'Загрузчик контрольных точек.<br>\r\nДавление в контрольных точках - метрики, отчеты и форма.<br>\r\nВычисление подач воды по управлению.<br>\r\nУлучшения и оптимизации.'),
(0, 4, '2019-01-29 00:00:00', 'Форма прочих показателей. Метрики по ОСК. Отчёт для технического директора по ОСК.<br>\r\nМетрики по Павловскому водохранилищу и реке. Загрузка метрик.<br>\r\nУлучшения и оптимизации.'),
(0, 5, '2019-01-30 00:00:00', 'Средние температуры - метрики, отчет, форма.<br>\r\nРеорганизация меню.<br>\r\nИсправлено: показ состояния записи в полях выбора.<br>\r\nУлучшения и оптимизации.'),
(0, 6, '2019-02-01 00:00:00', 'Форма по работе скважин.<br>\r\nЗагрузчик по скважинам.<br>\r\nОптимизация работы с метриками для загрузчиков.<br>\r\nОптимизация работы с форматами метрик.<br>\r\nМетрики и отчет по работе скважин.<br>\r\nОптимизации форм.'),
(0, 7, '2019-02-06 00:00:00', 'Оптимизация загрузчика данных.<br>\r\nПоля дат жесткости Шакша,Дема,КП,Нагаево, соответствующие метрики и форматы.<br>\r\nПриведены в порядок расчеты подач по управлению.<br>\r\nУбрано: Нагаево подача в город?<br>\r\nУлучшения и оптимизации.'),
(0, 8, '2019-02-07 00:00:00', 'Новый пользовательский интерфейс.<br>\r\nРеорганизация меню.<br>\r\nУлучшение формирования отчётов.'),
(0, 9, '2019-02-08 00:00:00', 'Изменение схемы формирования идентификаторов полей форм.<br>\r\nУлучшение форматирования вычисляемых полей.'),
(0, 10, '2019-02-25 00:00:00', 'Программа перенесена на рабочие сервера - доработки и улучшения, связанные с этим.<br>\r\nКод аутентификации и проверки пользователей.<br>\r\nСтраница для персонала службы АСУ.<br>\r\nАвтоматический редирект с начальной страницы в зависимости от роли пользователя.<br>\r\nИсправление проблемы с кодировкой.'),
(0, 11, '2019-03-04 00:00:00', 'Автоматизация установки программы.<br>\r\nОкно \"О программе\".<br>\r\nДоработки и оптимизации в коде авторизации.<br>\r\nДоработки интерфейса.'),
(0, 12, '2019-03-18 00:00:00', 'Перенос СУБД на рабочий сервер.<br>\r\nАктивация автоматической синхронизации данных.<br>\r\nУлучшение стабильности модуля синхронизации.<br>\r\nНовый \"безопасный\" модуль синхронизации, не копирующий поля данных уже заполненные в новой программе.<br>\r\nУлучшенное тестирование.'),
(0, 13, '2019-03-20 00:00:00', 'При открытии программы в качестве даты формирования выбирается вчерашняя дата,а не текущая.<br>\r\nПоддержка периодического запуска заданий переноса данных (шаблоны systemctl, cron, logrotate).<br>\r\nУлучшение безопасности (пакетная фильтрация на рабочих серверах).<br>\r\nДоработки загрузчиков данных.<br>\r\nСозданы установочные пакеты для установки ярлыка на рабочий стол пользователей.'),
(0, 14, '2019-03-22 00:00:00', 'Изменена верстка страницы работы скважин согласно запросам пользователей.<br>\r\nБлок с текстом отключений не переносится на отчете для ген.директора.<br>\r\nДоработки и исправления пользовательского интерфейса.'),
(0, 15, '2019-04-12 10:15:25', 'Оптимизация пользовательского интерфейса.<br>\r\nДокументация по заполнению параметров Нагаево и замечаниям. Доступна в меню \"Руководство пользователя\" и окне \"О программе\".'),
(0, 16, '2019-04-19 00:00:00', 'Работа над исправлением <a href=\"https://faq.uwc.ufanet.ru/doku.php?id=esv:zam\">замечаний ЦДС</a>.<br>\r\nИсправлено: замечание 1 - доработка верстки страницы \"Подано воды\".<br>\r\nИсправлено: замечание 2 - доработка верстки страницы \"Контрольные точки\".<br>\r\nИсправлено: замечание 3 - \"Прочие показатели\"- перенос единиц измерения, оптимизация верстки.<br>\r\nИсправлено: замечание 4 - перенос графы \"всего в ремонте\" после всех ремонтов.<br>\r\nИсправлено: замечание 6 - \"нет данных\" в отчетах по работе скважин.<br>\r\nОптимизация кода.\r\n'),
(0, 17, '2019-04-23 00:00:00', 'Исправлено: замечание 7 - сделан переход по полям по Enter.<br>\r\nИсправлено: замечание 6 - убрано \"н/д\" в отчете тех.директора по внеплановым отключениям при отсутствии введенных значений.<br>'),
(0, 18, '2019-05-06 00:00:00', 'Реализованы отчёты по периодам: 1) поднято I-подъемами, 2) подано в город, 3) уровень р.Уфа и параметры Павловского водохранилища, 4) подано на мехочистку и БОС ГОСК, 5) очищено ДЦК.<br>\r\nИсправлено: замечание 5 - отчёты по периодам,<br>\r\nзамечание 8 - сохранение отчётов в Google-диск, в Incoming.<br>\r\nИсправлено: при входе диспетчера ПЛК открывалась старая форма ввода параметров подачи, а не исправленная согласно замечаниям.<br>\r\nОптимизация создания отчётов, взаимодействия с СУБД.<br>\r\nУлучшения пользовательского интерфейса.'),
(0, 19, '2019-05-13 00:00:00', 'Реализована выгрузка данных отчётов по периодам в CSV формат (для Excel).<br>\r\nУлучшена проверка на тип используемого интернет-броузера.<br>\r\nМеню \"Настройки\", для дальнейшего развития.'),
(0, 20, '2019-05-20 00:00:00', 'Улучшение стабильности перезапуска (check_db_hosts)');

-- --------------------------------------------------------

--
-- Структура таблицы `formats`
--

CREATE TABLE `formats` (
  `id` varchar(50) NOT NULL,
  `form` varchar(255) NOT NULL,
  `report` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `formats`
--

INSERT INTO `formats` (`id`, `form`, `report`) VALUES
('1', '{\"type\":\"decimal\",\"round\":1}', '{\"type\":\"decimal\",\"round\":1}'),
('2', '{\"type\":\"decimal\",\"round\":2}', '{\"type\":\"decimal\",\"round\":2}'),
('3', '{\"type\":\"int\"}', '{\"type\":\"int\"}'),
('4', '{\"type\":\"text\"}', '{\"type\":\"text\"}'),
('5', '{\"type\":\"sost_lgosk\"}', '{\"type\":\"sost_lgosk\"}'),
('6', '{\"type\":\"date\"}', '{\"type\":\"date\"}');

-- --------------------------------------------------------

--
-- Структура таблицы `kt_defaults`
--

CREATE TABLE `kt_defaults` (
  `dest` varchar(30) NOT NULL,
  `sprav` float NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `kt_defaults`
--

INSERT INTO `kt_defaults` (`dest`, `sprav`) VALUES
('gors', 2.8),
('plk', 1.9),
('sgv_2p', 5.1),
('sgv_3p', 7.3);

-- --------------------------------------------------------

--
-- Структура таблицы `loaders_timestamp`
--

CREATE TABLE `loaders_timestamp` (
  `loader` char(30) NOT NULL,
  `timestamp` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `loaders_timestamp`
--

INSERT INTO `loaders_timestamp` (`loader`, `timestamp`) VALUES
('loader1', '2019-05-14 00:00:00'),
('loadersafe1', '2019-04-05 00:00:00');

-- --------------------------------------------------------

--
-- Структура таблицы `metrics`
--

CREATE TABLE `metrics` (
  `id` varchar(50) NOT NULL,
  `description` varchar(255) NOT NULL,
  `unit` varchar(30) NOT NULL,
  `measurement` varchar(50) NOT NULL,
  `tags` varchar(255) NOT NULL,
  `field` varchar(50) NOT NULL,
  `group` varchar(50) NOT NULL,
  `format` varchar(50) NOT NULL,
  `form_label` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `metrics`
--

INSERT INTO `metrics` (`id`, `description`, `unit`, `measurement`, `tags`, `field`, `group`, `format`, `form_label`) VALUES
('kt.cds.fact.max', 'КТ на М.Карима факт. давление - макс.(только старые данные)', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"cds\"}', 'max', '2', '1', 'Максимальное'),
('kt.cds.fact.min', 'КТ на М.Карима факт. давление - мин.(только старые данные)', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"cds\"}', 'min', '2', '1', 'Минимальное'),
('kt.cds.sprav', 'КТ на М.Карима справ. давление (только старые данные)', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"cds\"}', 'sprav', '2', '1', 'Не ниже'),
('kt.dram.fact.max', 'КТ Драмтеатр факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"dram\"}', 'max', '2', '1', 'Максимальное'),
('kt.dram.fact.min', 'КТ Драмтеатр факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"dram\"}', 'min', '2', '1', 'Минимальное'),
('kt.dynamo.fact.max', 'КТ Стадион Динамо факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"dynamo\"}', 'max', '2', '1', 'Максимальное'),
('kt.dynamo.fact.min', 'КТ Стадион Динамо факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"dynamo\"}', 'min', '2', '1', 'Минимальное'),
('kt.gors.fact.max', 'КТ Горсовет факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"gors\"}', 'max', '2', '1', 'Максимальное'),
('kt.gors.fact.min', 'КТ Горсовет факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"gors\"}', 'min', '2', '1', 'Минимальное'),
('kt.gors.sprav', 'КТ Горсовет справ. давление', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"gors\"}', 'sprav', '2', '1', 'Не ниже'),
('kt.oktrvk.fact.max', 'КТ Окт.РВК факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"oktrvk\"}', 'max', '2', '1', 'Максимальное'),
('kt.oktrvk.fact.min', 'КТ Окт.РВК факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"oktrvk\"}', 'min', '2', '1', 'Минимальное'),
('kt.plk.fact.max', 'КТ ПЛК факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"plk\"}', 'max', '2', '1', 'Максимальное'),
('kt.plk.fact.min', 'КТ ПЛК факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"plk\"}', 'min', '2', '1', 'Минимальное'),
('kt.plk.sprav', 'КТ ПЛК справ. давление', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"plk\"}', 'sprav', '2', '1', 'Не ниже'),
('kt.ptfab.podacha', 'Подано Птицефабрика (Как контрольная точка)', 'м<sup>3</sup>/сут.', 'kt', '{\"dest\":\"ptfab\"}', 'podacha', '2', '2', 'Объём'),
('kt.sgv_2p.fact.max', 'КТ 2-подъём СГВ факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"sgv_2p\"}', 'max', '2', '1', 'Максимальное'),
('kt.sgv_2p.fact.min', 'КТ 2-подъём СГВ факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"sgv_2p\"}', 'min', '2', '1', 'Минимальное'),
('kt.sgv_2p.sprav', 'КТ 2-подъём СГВ справ. давление', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"sgv_2p\"}', 'sprav', '2', '1', 'Не ниже'),
('kt.sgv_3p.fact.max', 'КТ 3-подъём СГВ факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"sgv_3p\"}', 'max', '2', '1', 'Максимальное'),
('kt.sgv_3p.fact.min', 'КТ 3-подъём СГВ факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"sgv_3p\"}', 'min', '2', '1', 'Минимальное'),
('kt.sgv_3p.sprav', 'КТ 3-подъём СГВ справ. давление', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"sgv_3p\"}', 'sprav', '2', '1', 'Не ниже'),
('kt.telc.fact.max', 'КТ Телецентр факт. давление - макс.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"telc\"}', 'max', '2', '1', 'Максимальное'),
('kt.telc.fact.min', 'КТ Телецентр факт. давление - мин.', 'кгс/см<sup>2</sup>', 'kt', '{\"dest\":\"telc\"}', 'min', '2', '1', 'Минимальное'),
('ostcl.dema.svob.max', 'Остаточный хлор свободный Дёма макс.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"dema\",\"cl_spec\":\"svob\"}', 'max', '0', '2', 'Свободный хлор'),
('ostcl.dema.svob.min', 'Остаточный хлор свободный Дёма мин.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"dema\",\"cl_spec\":\"svob\"}', 'min', '0', '2', 'Свободный хлор'),
('ostcl.iz.svob.max', 'Остаточный хлор свободный Изяк макс.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"iz\",\"cl_spec\":\"svob\"}', 'max', '0', '2', 'Свободный хлор'),
('ostcl.iz.svob.min', 'Остаточный хлор свободный Изяк мин.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"iz\",\"cl_spec\":\"svob\"}', 'min', '0', '2', 'Свободный хлор'),
('ostcl.sgv.max', 'Остаточный хлор СГВ макс.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"sgv\"}', 'max', '0', '2', 'Остаточный хлор'),
('ostcl.sgv.min', 'Остаточный хлор СГВ мин.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"sgv\"}', 'min', '0', '2', 'Остаточный хлор'),
('ostcl.skv.svaz.max', 'Остаточный хлор связанный СКВ макс.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"skv\",\"cl_spec\":\"svaz\"}', 'max', '0', '2', 'Связанный хлор'),
('ostcl.skv.svaz.min', 'Остаточный хлор связанный СКВ мин.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"skv\",\"cl_spec\":\"svaz\"}', 'min', '0', '2', 'Связанный хлор'),
('ostcl.skv.svob.max', 'Остаточный хлор свободный СКВ макс.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"skv\",\"cl_spec\":\"svob\"}', 'max', '0', '2', 'Свободный хлор'),
('ostcl.skv.svob.min', 'Остаточный хлор свободный СКВ мин.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"skv\",\"cl_spec\":\"svob\"}', 'min', '0', '2', 'Свободный хлор'),
('ostcl.uv.max', 'Остаточный хлор ЮГВ макс.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"uv\"}', 'max', '0', '2', 'Остаточный хлор'),
('ostcl.uv.min', 'Остаточный хлор ЮГВ мин.', 'мг/дм<sup>3</sup>', 'ostcl', '{\"dest\":\"uv\"}', 'min', '0', '2', 'Остаточный хлор'),
('otkl.plan', 'Плановые отключения (текстовое описание)', '', 'otkl', '{}', 'plan', '1', '4', ''),
('otkl.usvs.uvk.num_vneplan', 'Количество внеплановых отключений УСВС по инициативе УВК', '', 'otkl', '{\"dest\":\"usvs\",\"dest_spec\":\"uvk\"}', 'num_vneplan', '1', '3', 'Отключений'),
('otkl.usvs.zayav.num_vneplan', 'Количество внеплановых отключений УСВС по заявкам', '', 'otkl', '{\"dest\":\"usvs\",\"dest_spec\":\"zayav\"}', 'num_vneplan', '1', '3', 'Отключений'),
('otkl.uzvs.uvk.num_vneplan', 'Количество внеплановых отключений УЗВС по инициативе УВК', '', 'otkl', '{\"dest\":\"uzvs\",\"dest_spec\":\"uvk\"}', 'num_vneplan', '1', '3', 'Отключений'),
('otkl.uzvs.zayav.num_vneplan', 'Количество внеплановых отключений УЗВС по заявкам', '', 'otkl', '{\"dest\":\"uzvs\",\"dest_spec\":\"zayav\"}', 'num_vneplan', '1', '3', 'Отключений'),
('pavl.n_uroven', 'Павловское водохранилище, уровень нижнего бьефа', 'м', 'pavl', '{}', 'n_uroven', '3', '2', 'Ур.нижнего бьефа'),
('pavl.pritok', 'Павловское водохранилище, приток', 'м<sup>3</sup>/с', 'pavl', '{}', 'pritok', '3', '1', 'Приток'),
('pavl.sbros', 'Павловское водохранилище, сброс', 'м<sup>3</sup>/с', 'pavl', '{}', 'sbros', '3', '1', 'Сброс'),
('pavl.v_uroven', 'Павловское водохранилище, уровень верхнего бьефа', 'м', 'pavl', '{}', 'v_uroven', '3', '2', 'Ур.верхнего бьефа'),
('podacha.dema.deltamonth', 'Подано воды Дёма +/- с начала месяца', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"dema\",\"dest_spec\":\"\",\"rep_spec\":\"\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.dema.dema_1p.podyom', 'Подано воды Дема 1п. по БД', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"dema\",\"dest_spec\":\"dema_1p\",\"rep_spec\":\"\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.dema.dema_2p.gorod', 'Подано воды Дёма 2п. в город (поле gor4)', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"dema\",\"dest_spec\":\"dema_2p\",\"rep_spec\":\"\"}', 'gorod', '0', '2', 'Подано 2 подъём'),
('podacha.dema.dema_gorod.gorod', 'Подано воды Дёма в город (поле gor5)', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"dema\",\"dest_spec\":\"dema_gorod\",\"rep_spec\":\"\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.dema.gendir.deltamonth', 'Подано воды Дёма +/- с начала месяца для гендиректора', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"dema\",\"dest_spec\":\"\",\"rep_spec\":\"gendir\"}', 'deltamonth', '0', '2', '+/- для ген.дир-ра'),
('podacha.dema.podyom', 'Поднято воды Дёма 1п.', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"dema\",\"dest_spec\":\"\",\"rep_spec\":\"\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.iz.deltamonth', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"iz\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.iz.gorod', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"iz\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.iz.podyom', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"iz\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.kp.deltamonth', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"kp\",\"dest_spec\":\"\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.kp.kp_ikea.gorod', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"kp\",\"dest_spec\":\"kp_ikea\"}', 'gorod', '0', '2', 'На Икеа город'),
('podacha.kp.kp_ikea.podyom', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"kp\",\"dest_spec\":\"kp_ikea\"}', 'podyom', '0', '2', 'На Икеа 1 подъём'),
('podacha.kp.kp_itogo.gorod', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"kp\",\"dest_spec\":\"kp_itogo\"}', 'gorod', '0', '2', 'Итого в город'),
('podacha.kp.kp_itogo.podyom', 'Подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"kp\",\"dest_spec\":\"kp_itogo\"}', 'podyom', '0', '2', 'Итого 1 подъём'),
('podacha.nag.deltamonth', 'Нагаево подано +/-  с начала месяца', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"nag\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.nag.gorod', 'Нагаево подано воды в город (это фантастика?)', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"nag\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.nag.podyom', 'Нагаево поднято воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"nag\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.reka.mutnost', 'Мутность реки', 'мг/дм<sup>3</sup>', 'podacha', '{\"dest\":\"reka\"}', 'mutnost', '3', '2', 'Мутность реки'),
('podacha.reka.pr_ogolov', 'Превышение уровня реки над верхом оголовка', 'м', 'podacha', '{\"dest\":\"reka\"}', 'pr_ogolov', '3', '2', 'Прев.над верхом оголовка'),
('podacha.reka.uroven', 'Уровень реки', 'м', 'podacha', '{\"dest\":\"reka\"}', 'uroven', '3', '2', 'Уровень реки'),
('podacha.sgv.deltamonth', 'СГВ подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"sgv\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.sgv.gorod', 'СГВ подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"sgv\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.sgv.mutnost', 'Мутность резервуара СГВ', 'мг/дм<sup>3</sup>', 'podacha', '{\"dest\":\"sgv\"}', 'mutnost', '3', '2', 'Мут.резервуара СГВ'),
('podacha.sgv.podyom', 'СГВ подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"sgv\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.sh.deltamonth', 'Шакша подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"sh\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.sh.gorod', 'Шакша подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"sh\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.sh.podyom', 'Шакша подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"sh\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.skv.deltamonth', 'СКВ подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"skv\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.skv.gorod', 'СКВ подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"skv\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.skv.mutnost', 'Мутность резервуара СКВ', 'мг/дм<sup>3</sup>', 'podacha', '{\"dest\":\"skv\"}', 'mutnost', '3', '2', 'Мут.резервуара СКВ'),
('podacha.skv.podyom', 'СКВ подано воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"skv\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('podacha.skv.sob_nuzhdy', 'Вода на собственные нужды СКВ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"skv\"}', 'sob_nuzhdy', '3', '2', 'Соб.нужды СКВ'),
('podacha.uv.deltamonth', 'ЮВ подано воды +/- с начала месяца', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"uv\"}', 'deltamonth', '0', '2', '+/- с начала месяца'),
('podacha.uv.gorod', 'ЮВ подано в город воды ', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"uv\"}', 'gorod', '0', '2', 'Подано в город'),
('podacha.uv.podyom', 'ЮВ поднято 1 подъём', 'м<sup>3</sup>/сут.', 'podacha', '{\"dest\":\"uv\"}', 'podyom', '0', '2', 'Поднято 1 подъём'),
('skvag.dema.num_otkl', 'Количество отключенных скважин Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.dema.num_rab', 'Количество работающих скважин Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.dema.num_res', 'Количество скважин в резерве Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.dema.rem_all.num_rem', 'Всего скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.dema.rem_asu.num_rem', 'По АСУ скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.dema.rem_bezvod.num_rem', 'Без воды скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.dema.rem_elec.num_rem', 'По электрике скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.dema.rem_kipa.num_rem', 'По КИПиА скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.dema.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.dema.rem_otkach.num_rem', 'В откачке скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.dema.rem_skvag.num_rem', 'По скважинам скважин в ремонте Дема', '', 'skvag', '{\"dest\":\"dema\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('skvag.iz.num_otkl', 'Количество отключенных скважин Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.iz.num_rab', 'Количество работающих скважин Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.iz.num_res', 'Количество скважин в резерве Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.iz.rem_all.num_rem', 'Всего скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.iz.rem_asu.num_rem', 'По АСУ скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.iz.rem_bezvod.num_rem', 'Без воды скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.iz.rem_elec.num_rem', 'По электрике скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.iz.rem_kipa.num_rem', 'По КИПиА скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.iz.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.iz.rem_otkach.num_rem', 'В откачке скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.iz.rem_skvag.num_rem', 'По скважинам скважин в ремонте Изяк', '', 'skvag', '{\"dest\":\"iz\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('skvag.kp.num_otkl', 'Количество отключенных скважин Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.kp.num_rab', 'Количество работающих скважин Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.kp.num_res', 'Количество скважин в резерве Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.kp.rem_all.num_rem', 'Всего скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.kp.rem_asu.num_rem', 'По АСУ скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.kp.rem_bezvod.num_rem', 'Без воды скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.kp.rem_elec.num_rem', 'По электрике скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.kp.rem_kipa.num_rem', 'По КИПиА скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.kp.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.kp.rem_otkach.num_rem', 'В откачке скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.kp.rem_skvag.num_rem', 'По скважинам скважин в ремонте Кооперативная поляна', '', 'skvag', '{\"dest\":\"kp\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('skvag.nag.num_otkl', 'Количество отключенных скважин Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.nag.num_rab', 'Количество работающих скважин Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.nag.num_res', 'Количество скважин в резерве Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.nag.rem_all.num_rem', 'Всего скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.nag.rem_asu.num_rem', 'По АСУ скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.nag.rem_bezvod.num_rem', 'Без воды скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.nag.rem_elec.num_rem', 'По электрике скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.nag.rem_kipa.num_rem', 'По КИПиА скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.nag.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.nag.rem_otkach.num_rem', 'В откачке скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.nag.rem_skvag.num_rem', 'По скважинам скважин в ремонте Нагаево', '', 'skvag', '{\"dest\":\"nag\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('skvag.sgv.num_otkl', 'Количество отключенных скважин СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.sgv.num_rab', 'Количество работающих скважин СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.sgv.num_res', 'Количество скважин в резерве СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.sgv.rem_all.num_rem', 'Всего скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.sgv.rem_asu.num_rem', 'По АСУ скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.sgv.rem_bezvod.num_rem', 'Без воды скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.sgv.rem_elec.num_rem', 'По электрике скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.sgv.rem_kipa.num_rem', 'По КИПиА скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.sgv.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.sgv.rem_otkach.num_rem', 'В откачке скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.sgv.rem_skvag.num_rem', 'По скважинам скважин в ремонте СГВ', '', 'skvag', '{\"dest\":\"sgv\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('skvag.sh.num_otkl', 'Количество отключенных скважин Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.sh.num_rab', 'Количество работающих скважин Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.sh.num_res', 'Количество скважин в резерве Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.sh.rem_all.num_rem', 'Всего скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.sh.rem_asu.num_rem', 'По АСУ скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.sh.rem_bezvod.num_rem', 'Без воды скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.sh.rem_elec.num_rem', 'По электрике скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.sh.rem_kipa.num_rem', 'По КИПиА скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.sh.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.sh.rem_otkach.num_rem', 'В откачке скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.sh.rem_skvag.num_rem', 'По скважинам скважин в ремонте Шакша', '', 'skvag', '{\"dest\":\"sh\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('skvag.uv.num_otkl', 'Количество отключенных скважин ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"\"}', 'num_otkl', '5', '3', 'Отключено'),
('skvag.uv.num_rab', 'Количество работающих скважин ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"\"}', 'num_rab', '5', '3', 'В работе'),
('skvag.uv.num_res', 'Количество скважин в резерве ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"\"}', 'num_res', '5', '3', 'В резерве'),
('skvag.uv.rem_all.num_rem', 'Всего скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_all\"}', 'num_rem', '5', '3', 'В ремонте всего'),
('skvag.uv.rem_asu.num_rem', 'По АСУ скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_asu\"}', 'num_rem', '5', '3', 'По АСУ'),
('skvag.uv.rem_bezvod.num_rem', 'Без воды скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_bezvod\"}', 'num_rem', '5', '3', 'Без воды'),
('skvag.uv.rem_elec.num_rem', 'По электрике скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_elec\"}', 'num_rem', '5', '3', 'Электр.часть'),
('skvag.uv.rem_kipa.num_rem', 'По КИПиА скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_kipa\"}', 'num_rem', '5', '3', 'КИПиА'),
('skvag.uv.rem_nasos.num_rem', 'По насосам \r\nскважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_nasos\"}', 'num_rem', '5', '3', 'Насосы'),
('skvag.uv.rem_otkach.num_rem', 'В откачке скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_otkach\"}', 'num_rem', '5', '3', 'В откачке'),
('skvag.uv.rem_skvag.num_rem', 'По скважинам скважин в ремонте ЮВ', '', 'skvag', '{\"dest\":\"uv\",\"rem_spec\":\"rem_skvag\"}', 'num_rem', '5', '3', 'Скважины'),
('stok.dck.och', 'ДЦК очищено сточной воды', 'м<sup>3</sup>/сут.', 'stok', '{\"dest\":\"dck\"}', 'och', '4', '1', 'ДЦК очищено'),
('stok.gosk.gosk_3bl.och', 'ГОСК принято III-блок', 'м<sup>3</sup>/сут.', 'stok', '{\"dest\":\"gosk\",\"dest_spec\":\"gosk_3bl\"}', 'och', '4', '1', 'ГОСК III-блок'),
('stok.gosk.gosk_4bl.och', 'ГОСК принято IV-блок', 'м<sup>3</sup>/сут.', 'stok', '{\"dest\":\"gosk\",\"dest_spec\":\"gosk_4bl\"}', 'och', '4', '1', 'ГОСК IV-блок'),
('stok.gosk.gosk_bos.och', 'ГОСК принято на БОС', 'м<sup>3</sup>/сут.', 'stok', '{\"dest\":\"gosk\",\"dest_spec\":\"gosk_bos\"}', 'och', '4', '1', 'ГОСК БОС'),
('stok.gosk.gosk_meh.och', 'ГОСК принято сточных вод на механическую очистку', 'м<sup>3</sup>/сут.', 'stok', '{\"dest\":\"gosk\",\"dest_spec\":\"gosk_meh\"}', 'och', '4', '1', 'ГОСК мех.оч.'),
('stok.lgosk.decanter1.sost', 'Левый берег ГОСК Код состояния Декантер 1', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"decanter1\"}', 'sost', '4', '5', 'Декантер №1'),
('stok.lgosk.decanter2.sost', 'Левый берег ГОСК Код состояния Декантер 2', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"decanter2\"}', 'sost', '4', '5', 'Декантер №2'),
('stok.lgosk.decanter3.sost', 'Левый берег ГОСК Код состояния Декантер 3', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"decanter3\"}', 'sost', '4', '5', 'Декантер №3'),
('stok.lgosk.kotel1.sost', 'Левый берег ГОСК Код состояния Котёл 1', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"kotel1\"}', 'sost', '4', '5', 'Котёл №1'),
('stok.lgosk.kotel2.sost', 'Левый берег ГОСК Код состояния Котёл 2', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"kotel2\"}', 'sost', '4', '5', 'Котёл №2'),
('stok.lgosk.kotel3.sost', 'Левый берег ГОСК Код состояния Котёл 3', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"kotel3\"}', 'sost', '4', '5', 'Котёл №3'),
('stok.lgosk.kotel4.sost', 'Левый берег ГОСК Код состояния Котёл 4', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"kotel4\"}', 'sost', '4', '5', 'Котёл №4'),
('stok.lgosk.obezv.osadok', 'Лев.берег ОСК количество обезвоженного  осадка', 'м<sup>3</sup>', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"obezv\"}', 'osadok', '4', '1', 'Количество'),
('stok.lgosk.obezv.vlazh', 'Лев.берег ОСК влажность обезвоженного  осадка', '%', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"obezv\"}', 'vlazh', '4', '1', 'Влажность'),
('stok.lgosk.pererab.osadok', 'Лев.берег ОСК количество переработанного осадка', 'т', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"pererab\"}', 'osadok', '4', '1', 'Количество'),
('stok.lgosk.pererab.vlazh', 'Лев.берег ОСК влажность переработанного осадка', '%', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"pererab\"}', 'vlazh', '4', '1', 'Влажность'),
('stok.lgosk.sushka1.sost', 'Левый берег ГОСК Код состояния Сушильная линия 1', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"sushka1\"}', 'sost', '4', '5', 'Сушка №1'),
('stok.lgosk.sushka2.sost', 'Левый берег ГОСК Код состояния Сушильная линия 2', 'выбор', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"sushka2\"}', 'sost', '4', '5', 'Сушка №2'),
('stok.lgosk.vysush.osadok', 'Лев.берег ОСК количество высушенного осадка', 'т', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"vysush\"}', 'osadok', '4', '1', 'Количество'),
('stok.lgosk.vysush.vlazh', 'Лев.берег ОСК влажность высушенного осадка', '%', 'stok', '{\"dest\":\"lgosk\",\"dest_spec\":\"vysush\"}', 'vlazh', '4', '1', 'Влажность'),
('temp.gosk.dayavg', 'ГОСК средняя температура наружного воздуха', '&deg;C', 'temp', '{\"dest\":\"gosk\"}', 'dayavg', '3', '2', 'ГОСК'),
('temp.iv2.dayavg', 'ИВ-2 средняя температура наружного воздуха', '&deg;C', 'temp', '{\"dest\":\"iv2\"}', 'dayavg', '3', '2', 'ИВ-2'),
('temp.skv1.dayavg', 'СКВ-1 средняя температура наружного воздуха', '&deg;C', 'temp', '{\"dest\":\"skv1\"}', 'dayavg', '3', '2', 'СКВ-1'),
('temp.uv2.dayavg', 'ЮВ-2 средняя температура наружного воздуха', '&deg;C', 'temp', '{\"dest\":\"uv2\"}', 'dayavg', '3', '2', 'ЮВ-2'),
('zhost.dema.date', 'Дёма. Дата показания жесткости', 'дд.мм.гггг', 'zhost', '{\"dest\":\"dema\"}', 'date', '0', '6', 'Дата жёсткости'),
('zhost.dema.max', 'Жесткость воды Дёма', '&deg;ж', 'zhost', '{\"dest\":\"dema\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.iz.max', 'Жесткость воды Изяк', '&deg;ж', 'zhost', '{\"dest\":\"iz\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.kp.date', 'Кооперативная поляна. Дата показания жесткости', 'дд.мм.гггг', 'zhost', '{\"dest\":\"kp\"}', 'date', '0', '6', 'Дата жёсткости'),
('zhost.kp.max', 'Жесткость воды Кооперативная поляна', '&deg;ж', 'zhost', '{\"dest\":\"kp\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.nag.date', 'Нагаево. Дата показания жесткости', 'дд.мм.гггг', 'zhost', '{\"dest\":\"nag\"}', 'date', '0', '6', 'Дата жёсткости'),
('zhost.nag.max', 'Жесткость воды Нагаево', '&deg;ж', 'zhost', '{\"dest\":\"nag\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.sgv.max', 'Жесткость воды СГВ', '&deg;ж', 'zhost', '{\"dest\":\"sgv\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.sh.date', 'Шакша. Дата показания жесткости', 'дд.мм.гггг', 'zhost', '{\"dest\":\"sh\"}', 'date', '0', '6', 'Дата жёсткости'),
('zhost.sh.max', 'Жесткость воды Шакша', '&deg;ж', 'zhost', '{\"dest\":\"sh\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.skv.max', 'Жесткость воды СКВ', '&deg;ж', 'zhost', '{\"dest\":\"skv\"}', 'max', '0', '1', 'Жёсткость'),
('zhost.uv.max', 'Жесткость воды ЮВ', '&deg;ж', 'zhost', '{\"dest\":\"uv\"}', 'max', '0', '1', 'Жёсткость');

-- --------------------------------------------------------

--
-- Структура таблицы `select_groups`
--

CREATE TABLE `select_groups` (
  `id` varchar(50) NOT NULL,
  `fieldspec` varchar(255) NOT NULL,
  `measpec` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `select_groups`
--

INSERT INTO `select_groups` (`id`, `fieldspec`, `measpec`) VALUES
('0', 'dest,dest_spec,rep_spec,podyom,gorod,deltamonth,cl_spec,max,min,date', 'podacha,zhost,ostcl'),
('1', 'dest,dest_spec,plan,num_vneplan', 'otkl'),
('2', 'dest,max,min,sprav,podacha', 'kt'),
('3', 'dest,sob_nuzhdy,uroven,mutnost,pr_ogolov,pritok,sbros,v_uroven,n_uroven,dayavg', 'podacha,pavl,temp'),
('4', 'dest,dest_spec,och,osadok,vlazh,sost', 'stok'),
('5', 'dest,rem_spec,num_rab,num_res,num_otkl,num_rem', 'skvag');

-- --------------------------------------------------------

--
-- Структура таблицы `users`
--

CREATE TABLE `users` (
  `login` varchar(50) NOT NULL,
  `role` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Дамп данных таблицы `users`
--

INSERT INTO `users` (`login`, `role`) VALUES
('cdsdisp', 'cds'),
('cdsnach', 'cds'),
('cds_tech@uwc.ufanet.ru', 'cds'),
('chernetsov', 'tehdir'),
('nail', 'asu'),
('nikitin', 'gendir'),
('nogotkov', 'asu'),
('panasenko', 'asu'),
('serebryakov', 'cds'),
('ural', 'asu');

--
-- Индексы сохранённых таблиц
--

--
-- Индексы таблицы `changelog`
--
ALTER TABLE `changelog`
  ADD PRIMARY KEY (`ver_major`,`ver_minor`);

--
-- Индексы таблицы `formats`
--
ALTER TABLE `formats`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `kt_defaults`
--
ALTER TABLE `kt_defaults`
  ADD PRIMARY KEY (`dest`);

--
-- Индексы таблицы `loaders_timestamp`
--
ALTER TABLE `loaders_timestamp`
  ADD PRIMARY KEY (`loader`);

--
-- Индексы таблицы `metrics`
--
ALTER TABLE `metrics`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `select_groups`
--
ALTER TABLE `select_groups`
  ADD PRIMARY KEY (`id`);

--
-- Индексы таблицы `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`login`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
