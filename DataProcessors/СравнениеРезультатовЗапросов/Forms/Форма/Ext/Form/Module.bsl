﻿
#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ВывестиСтрокиЭтойБазы = Истина;
	ВывестиСтрокиПодключеннойБазы = Истина;
	ВывестиСтрокиРазличающиеся = Истина;
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы


#Область КонструкторЗапроса

&НаКлиенте
Процедура ОткрытьКонструкторЗапросаЭтойБазы(Команда)
	
	Если ЗначениеЗаполнено(ТекстЗапросаЭтойБазы) Тогда
		Конструктор = Новый КонструкторЗапроса(ТекстЗапросаЭтойБазы);
	Иначе
		Конструктор = Новый КонструкторЗапроса;
	КонецЕсли;
	ОписаниеОповещения = Новый ОписаниеОповещения("ЗакрытиеКонструктораЗапросаЭтойБазы", ЭтотОбъект);
	Конструктор.Показать(ОписаниеОповещения);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗакрытиеКонструктораЗапросаЭтойБазы(ТекстЗапросаИзКонструктора, ДополнительныеПараметры) Экспорт
	
	ТекстЗапросаЭтойБазы = ТекстЗапросаИзКонструктора;
	Если ЗначениеЗаполнено(ТекстЗапросаЭтойБазы) Тогда
		ПолучитьПараметрыЗапросаНаСервере();
	КонецЕсли;
	
КонецПроцедуры
	
#КонецОбласти

#Область ПараметрыЗапроса

&НаКлиенте
Процедура ПолучитьПараметрыЗапросаЭтойБазы(Команда)
	ПолучитьПараметрыЗапросаНаСервере();
КонецПроцедуры

&НаСервере
Процедура ПолучитьПараметрыЗапросаНаСервере()
	ПараметрыЗапросаЭтойБазы.Очистить();
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапросаЭтойБазы;
	ОписаниеПараметров = Запрос.НайтиПараметры();
	
	тзПараметрыЗапроса = ПараметрыЗапросаЭтойБазы.Выгрузить();
	Для Каждого ОписаниеПараметра Из ОписаниеПараметров Цикл
		РедактСтрокаТЗ = тзПараметрыЗапроса.Найти(ОписаниеПараметра.Имя, "ИмяПараметра");
		Если РедактСтрокаТЗ = Неопределено Тогда
			РедактСтрокаТЗ = тзПараметрыЗапроса.Добавить();
			РедактСтрокаТЗ.ИмяПараметра = ОписаниеПараметра.Имя;
		КонецЕсли;
		РедактСтрокаТЗ.ТипПараметра = ОписаниеПараметра.ТипЗначения;
		РедактСтрокаТЗ.ЗначениеПараметра = РедактСтрокаТЗ.ТипПараметра.ПривестиЗначение(РедактСтрокаТЗ.ЗначениеПараметра);
	КонецЦикла;
	
	 ПараметрыЗапросаЭтойБазы.Загрузить(тзПараметрыЗапроса);
КонецПроцедуры

#КонецОбласти

#Область СравнениеРезультатовЗапросов

&НаКлиенте
Процедура СравнитьРезультатыЗапросов(Команда)
	
	Если СтрНайти(ТекстЗапросаЭтойБазы, "_Ключ") = 0 Тогда
		ПоказатьПредупреждение(, "В запросе не указано ни одно ключевое поле (оканчивающееся на ""_Ключ""))");
		Возврат;
	КонецЕсли;
	
	Результат = СравнитьРезультатыЗапросовНаСервере();
	Если Не ПустаяСтрока(Результат) тогда
		Предупреждение(Результат);
	КонецЕсли;	
КонецПроцедуры

&НаСервере
Функция СравнитьРезультатыЗапросовНаСервере()
	
	тзЭтойБазы = ПолучитьДанныеЭтойБазы();
	
	Колонки = ПолучитьМассивыКолонок(тзЭтойБазы);
	Результат = ПолучитьДанныеДругойБазы();
	Если ТипЗнч(Результат) = Тип("Строка") тогда
		Возврат Результат	
	иначе	
		тзДругойБазы = Результат.Объекты;
	КонецЕсли;
	СтрокиТЗ = ПолучитьСтрокиРазличийТаблицЗначений(тзЭтойБазы, тзДругойБазы, Колонки);
	ВывестиРезультатСравненияВТабличныйДокумент(СтрокиТЗ, Колонки, Неопределено);
	Возврат "";
КонецФункции

&НаСервере
Функция ПолучитьДанныеЭтойБазы()
	
	Запрос = Новый Запрос;
	Запрос.Текст = ТекстЗапросаЭтойБазы;
	Для Каждого СтрокаПараметр Из ПараметрыЗапросаЭтойБазы Цикл
		Запрос.УстановитьПараметр(СтрокаПараметр.ИмяПараметра, СтрокаПараметр.ЗначениеПараметра);
	КонецЦикла;
	тзЭтойБазы = Запрос.Выполнить().Выгрузить(); 
	
	Возврат тзЭтойБазы;
	
КонецФункции

&НаСервере
Функция ПолучитьМассивыКолонок(тзЭтойБазы)
	
	ПримитивныеТипы = МассивПримитивныхТипов();
	
	Колонки = Новый Структура;
	Колонки.Вставить("Все", Новый Массив);
	Колонки.Вставить("Ключевые", Новый Массив);
	Колонки.Вставить("КлючевыеДляЗаголовков", Новый Массив);	
	Колонки.Вставить("СтруктураПоиска", Новый Массив);
	Колонки.Вставить("Остальные", Новый Массив);
	Колонки.Вставить("Ссылочные", Новый Массив);
	Колонки.Вставить("Перечисления", Новый Массив);
	
	МенеджерыПеречислений = Новый Соответствие;
	
	Для Каждого КолонкаТЗ Из тзЭтойБазы.Колонки Цикл
		ЕстьСсылки = Ложь;
		ЭтоПеречисление = Ложь;
		ТипыКолонки = КолонкаТЗ.ТипЗначения.Типы();
		Для Каждого ТекТип Из ТипыКолонки Цикл
			Если ПримитивныеТипы.Найти(ТекТип) = Неопределено Тогда
				ПолноеИмяМетаданных = Метаданные.НайтиПоТипу(ТекТип).ПолноеИмя();
				Если Лев(НРег(ПолноеИмяМетаданных), 13) = "перечисление." Тогда
					ЭтоПеречисление = Истина;
					МенеджерыПеречислений.Вставить(Метаданные.НайтиПоПолномуИмени(ПолноеИмяМетаданных));
				КонецЕсли;
				
				ЕстьСсылки = Истина;
				Прервать;
				
			КонецЕсли;
		КонецЦикла;
		Если ЕстьСсылки Тогда
			Колонки.Ссылочные.Добавить(КолонкаТЗ.Имя);
		КонецЕсли;
		Если ЭтоПеречисление Тогда
			Колонки.Перечисления.Добавить(КолонкаТЗ.Имя);
		КонецЕсли;
		
		Если Прав(КолонкаТЗ.Имя, 5) = "_Ключ" Тогда
			Колонки.Ключевые.Добавить(КолонкаТЗ.Имя);
			Колонки.КлючевыеДляЗаголовков.Добавить(СтрЗаменить(КолонкаТЗ.Имя, "_Ключ", ""));
			Колонки.СтруктураПоиска.Добавить(КолонкаТЗ.Имя);
		Иначе
			Колонки.Остальные.Добавить(КолонкаТЗ.Имя);
		КонецЕсли;
	КонецЦикла;
	
	Колонки.Вставить("СоотвПеречислений", Новый Соответствие);
	Для Каждого КЗ Из МенеджерыПеречислений Цикл
		МенеджерПеречисления = КЗ.Ключ;
		Для Каждого ЗначениеПеречисления Из МенеджерПеречисления.ЗначенияПеречисления Цикл
			Колонки.СоотвПеречислений.Вставить(Перечисления[МенеджерПеречисления.Имя][ЗначениеПеречисления.Имя], ЗначениеПеречисления.Имя);
		КонецЦикла;
	КонецЦикла;
	
	Возврат Колонки;
	
КонецФункции

&НаСервере
Функция ПолучитьДанныеДругойБазы()
	ДанныеОтправки = Новый Структура;
	ДанныеОтправки.Вставить("ТекстЗапроса", ТекстЗапросаЭтойБазы);
	ДанныеОтправки.Вставить("ПараметрыЗапроса", РеквизитФормыВЗначение("ПараметрыЗапросаЭтойБазы"));
	Результат = СРМ_ОбменВебСервис.СверкаБаз(ДанныеОтправки);
	Возврат Результат;
КонецФункции

&НаСервере
Функция ПолучитьСтрокиРазличийТаблицЗначений(тзЭтойБазы, тзДругойБазы, Колонки)
	
	тзЭтойБазы.Колонки.Добавить("СтрокаУчтена");
	тзЭтойБазы.ЗаполнитьЗначения(Ложь, "СтрокаУчтена");
	
	тзДругойБазы.Колонки.Добавить("СтрокаУчтена");
	тзДругойБазы.ЗаполнитьЗначения(Ложь, "СтрокаУчтена");
	
	СтрокаКолонкиДляПоиска = СтрСоединить(Колонки.СтруктураПоиска, ",");
	тзЭтойБазы.Индексы.Добавить(СтрокаКолонкиДляПоиска+",СтрокаУчтена");
	тзДругойБазы.Индексы.Добавить(СтрокаКолонкиДляПоиска+",СтрокаУчтена");
	
	СтрокиТЗ = Новый Структура;
	СтрокиТЗ.Вставить("ТолькоЭтаБаза", Новый Массив);
	СтрокиТЗ.Вставить("ТолькоДругаяБаза", Новый Массив);
	СтрокиТЗ.Вставить("ОтличающиесяЭтаБаза", Новый Массив);
	СтрокиТЗ.Вставить("ОтличающиесяДругаяБаза", Новый Массив);
	СтрокиТЗ.Вставить("СовпадающиеЭтаБаза", Новый Массив);
	
	Для Каждого ЭтаБазаСтрока Из тзЭтойБазы Цикл
		СтруктураПоиска = Новый Структура(СтрокаКолонкиДляПоиска);
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, ЭтаБазаСтрока);
		СтруктураПоиска.Вставить("СтрокаУчтена", Ложь);
		
		МассивНайдСтрок = тзДругойБазы.НайтиСтроки(СтруктураПоиска);
		Если МассивНайдСтрок.Количество() = 0 Тогда
			СтрокиТЗ.ТолькоЭтаБаза.Добавить(ЭтаБазаСтрока);
		Иначе
			ЗначенияСовпадают = Истина;
			СтрокаДругойБазы = МассивНайдСтрок[0];
			Для Каждого ОстальнаяКолонка Из Колонки.Остальные Цикл
				ЗначенияСовпадают = ЗначенияСовпадают(ЭтаБазаСтрока, СтрокаДругойБазы, ОстальнаяКолонка, Колонки);
				Если НЕ ЗначенияСовпадают Тогда
					Прервать;
				КонецЕсли;
			КонецЦикла;
			Если ЗначенияСовпадают Тогда
				ЭтаБазаСтрока.СтрокаУчтена = Истина;
				СтрокаДругойБазы.СтрокаУчтена = Истина;
				СтрокиТЗ.СовпадающиеЭтаБаза.Добавить(ЭтаБазаСтрока);
			Иначе
				СтрокиТЗ.ОтличающиесяЭтаБаза.Добавить(ЭтаБазаСтрока);
				СтрокиТЗ.ОтличающиесяДругаяБаза.Добавить(СтрокаДругойБазы);
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого ДругаяБазаСтрока Из тзДругойБазы Цикл
		Если ДругаяБазаСтрока.СтрокаУчтена Тогда
			Продолжить;
		КонецЕсли;
		СтруктураПоиска = Новый Структура(СтрокаКолонкиДляПоиска);
		ЗаполнитьЗначенияСвойств(СтруктураПоиска, ДругаяБазаСтрока);
		СтруктураПоиска.Вставить("СтрокаУчтена", Ложь);
		
		МассивНайдСтрок = тзЭтойБазы.НайтиСтроки(СтруктураПоиска);
		Если МассивНайдСтрок.Количество() = 0 Тогда
			СтрокиТЗ.ТолькоДругаяБаза.Добавить(ДругаяБазаСтрока);
		КонецЕсли;
	КонецЦикла;
	
	Возврат СтрокиТЗ;
	
КонецФункции

&НаСервере
Процедура ВывестиРезультатСравненияВТабличныйДокумент(СтрокиТЗ, Колонки, КОМСоединение)
	
	ОбрОбъект = РеквизитФормыВЗначение("Объект");
	
	Макет = ОбрОбъект.ПолучитьМакет("Различия");
	
	Обл = Новый Структура;
	
	Обл.Вставить("Заголовок", Макет.ПолучитьОбласть("Заголовок"));
	Обл.Вставить("Пояснение", Макет.ПолучитьОбласть("Пояснение"));
	
	Обл.Вставить("ШапкаНачало", Макет.ПолучитьОбласть("Шапка|Начало"));
	Обл.Вставить("ШапкаСтолбец", Макет.ПолучитьОбласть("Шапка|Столбец"));
	
	Обл.Вставить("СтрокаНачало", Макет.ПолучитьОбласть("Строка|Начало"));
	Обл.Вставить("СтрокаСтолбец", Макет.ПолучитьОбласть("Строка|Столбец"));
	
	Обл.Вставить("СтрокаРазличийНетНачало", Макет.ПолучитьОбласть("СтрокаРазличийНет|Начало"));
	Обл.Вставить("СтрокаРазличийНетСтолбец", Макет.ПолучитьОбласть("СтрокаРазличийНет|Столбец"));
	Обл.Вставить("СтрокаРазличияЕстьСтолбец", Макет.ПолучитьОбласть("СтрокаРазличияЕсть|Столбец"));
	
	РезультатСравнения.Очистить();
	
	РезультатСравнения.НачатьАвтогруппировкуСтрок();
	
	Если ВывестиСовпавшие Тогда
		Обл.Заголовок.Параметры.Заголовок = "Строки, совпавшие в обоих базах: "+СтрокиТЗ.СовпадающиеЭтаБаза.Количество();
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
		ВывестиТаблицуВТабличныйДокумент(РезультатСравнения, СтрокиТЗ.СовпадающиеЭтаБаза, Обл, Колонки, Неопределено);
		
	Иначе
		Обл.Заголовок.Параметры.Заголовок = "Количество совпавших строк: "+СтрокиТЗ.СовпадающиеЭтаБаза.Количество();
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
		
	КонецЕсли;
	
	Если ВывестиСтрокиЭтойБазы Тогда
		Обл.Заголовок.Параметры.Заголовок = "Строки, присутствующие только в этой базе ("+СтрокиТЗ.ТолькоЭтаБаза.Количество()+")";
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
		ВывестиТаблицуВТабличныйДокумент(РезультатСравнения, СтрокиТЗ.ТолькоЭтаБаза, Обл, Колонки, Неопределено);
	Иначе
		Обл.Заголовок.Параметры.Заголовок = "Количество строк, присутствующих только в этой базе: "+СтрокиТЗ.ТолькоЭтаБаза.Количество();
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
	КонецЕсли;
	
	
	Если ВывестиСтрокиПодключеннойБазы Тогда
		Обл.Заголовок.Параметры.Заголовок = "Строки, присутствующие только в подключенной базе ("+СтрокиТЗ.ТолькоДругаяБаза.Количество()+")";
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
		ВывестиТаблицуВТабличныйДокумент(РезультатСравнения, СтрокиТЗ.ТолькоДругаяБаза, Обл, Колонки, КОМСоединение);
	Иначе
		Обл.Заголовок.Параметры.Заголовок = "Количество строк, присутствующих только в подключенной базе: "+СтрокиТЗ.ТолькоДругаяБаза.Количество();
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
	КонецЕсли;
	
	Если ВывестиСтрокиРазличающиеся Тогда
		Обл.Заголовок.Параметры.Заголовок = "Строки, отличающиеся значениями неключевых колонок ("+СтрокиТЗ.ОтличающиесяЭтаБаза.Количество()+")";
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
		Обл.Пояснение.Параметры.Пояснение = "В строке: сверху значение в этой базе, снизу значение в подключенной базе";
		РезультатСравнения.Вывести(Обл.Пояснение, 0);
		Если СтрокиТЗ.ОтличающиесяЭтаБаза.Количество() > 0 Тогда
			РезультатСравнения.Вывести(Обл.ШапкаНачало, 0);
			Для Каждого ИмяКолонки Из Колонки.КлючевыеДляЗаголовков Цикл
				Обл.ШапкаСтолбец.Параметры.ИмяКолонки = ИмяКолонки;
				РезультатСравнения.Присоединить(Обл.ШапкаСтолбец);
			КонецЦикла;
			Для Каждого ИмяКолонки Из Колонки.Остальные Цикл
				Обл.ШапкаСтолбец.Параметры.ИмяКолонки = ИмяКолонки;
				РезультатСравнения.Присоединить(Обл.ШапкаСтолбец);
			КонецЦикла;
		КонецЕсли;
		Для ТекИнд = 0 По СтрокиТЗ.ОтличающиесяЭтаБаза.ВГраница() Цикл
			РезультатСравнения.Вывести(Обл.СтрокаРазличийНетНачало, 1);
			Для Каждого ИмяКолонки Из Колонки.Ключевые Цикл
				Обл.СтрокаРазличийНетСтолбец.Параметры.ЗначениеКолонкиЭтойБазы = СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд][ИмяКолонки];
				Если Колонки.Ссылочные.Найти(ИмяКолонки) <> Неопределено Тогда
					Обл.СтрокаРазличийНетСтолбец.Параметры.ЗначениеРасшифровкиКолонкиЭтойБазы = СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд][ИмяКолонки]; 
				КонецЕсли;
				Обл.СтрокаРазличийНетСтолбец.Параметры.ЗначениеКолонкиДругойБазы = СтрокиТЗ.ОтличающиесяДругаяБаза[ТекИнд][ИмяКолонки];
				
				ВыведОбл = РезультатСравнения.Присоединить(Обл.СтрокаРазличийНетСтолбец);
				ОбъедОбл = РезультатСравнения.Область(ВыведОбл.Верх, ВыведОбл.Лево, ВыведОбл.Низ, ВыведОбл.Лево);
				ОбъедОбл.Объединить();
				ОбъедОбл.ВертикальноеПоложение = ВертикальноеПоложение.Верх;
			КонецЦикла;
			Для Каждого ИмяКолонки Из Колонки.Остальные Цикл
				Если ЗначенияСовпадают(СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд], СтрокиТЗ.ОтличающиесяДругаяБаза[ТекИнд], ИмяКолонки, Колонки) Тогда
					Обл.СтрокаРазличийНетСтолбец.Параметры.ЗначениеКолонкиЭтойБазы = СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд][ИмяКолонки];
					Если Колонки.Ссылочные.Найти(ИмяКолонки) <> Неопределено Тогда
						Обл.СтрокаРазличийНетСтолбец.Параметры.ЗначениеРасшифровкиКолонкиЭтойБазы = СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд][ИмяКолонки];
					КонецЕсли;
					Обл.СтрокаРазличийНетСтолбец.Параметры.ЗначениеКолонкиДругойБазы = СтрокиТЗ.ОтличающиесяДругаяБаза[ТекИнд][ИмяКолонки];
					
					РезультатСравнения.Присоединить(Обл.СтрокаРазличийНетСтолбец);				
				Иначе
					Обл.СтрокаРазличияЕстьСтолбец.Параметры.ЗначениеКолонкиЭтойБазы = СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд][ИмяКолонки];
					Если Колонки.Ссылочные.Найти(ИмяКолонки) <> Неопределено Тогда
						Обл.СтрокаРазличияЕстьСтолбец.Параметры.ЗначениеРасшифровкиКолонкиЭтойБазы = СтрокиТЗ.ОтличающиесяЭтаБаза[ТекИнд][ИмяКолонки];
					КонецЕсли;
					Обл.СтрокаРазличияЕстьСтолбец.Параметры.ЗначениеКолонкиДругойБазы = СтрокиТЗ.ОтличающиесяДругаяБаза[ТекИнд][ИмяКолонки];
					
					РезультатСравнения.Присоединить(Обл.СтрокаРазличияЕстьСтолбец);
				КонецЕсли;
			КонецЦикла;		
		КонецЦикла;
	Иначе
		Обл.Заголовок.Параметры.Заголовок = "Количество строк, отличающимися значениями неключевых колонок: "+СтрокиТЗ.ОтличающиесяЭтаБаза.Количество();
		РезультатСравнения.Вывести(Обл.Заголовок, 0);
	КонецЕсли;
	
	РезультатСравнения.ЗакончитьАвтогруппировкуСтрок();
	РезультатСравнения.ПоказатьУровеньГруппировокСтрок(0);
		
КонецПроцедуры
		
#КонецОбласти

#КонецОбласти


#Область СлужебныеПроцедурыИФункции

&НаСервереБезКонтекста
Функция МассивПримитивныхТипов()
	
	ПримитивныеТипы = Новый Массив;
	ПримитивныеТипы.Добавить(Тип("Null"));
	ПримитивныеТипы.Добавить(Тип("Строка"));
	ПримитивныеТипы.Добавить(Тип("Число"));
	ПримитивныеТипы.Добавить(Тип("Дата"));
	ПримитивныеТипы.Добавить(Тип("Булево"));
	
	Возврат ПримитивныеТипы;
	
КонецФункции

&НаСервереБезКонтекста
Функция ЗначенияСовпадают(Строка1, Строка2, ИмяКолонки, Колонки)
	
	Если Колонки.Ссылочные.Найти(ИмяКолонки) = Неопределено Тогда
		Если Строка1[ИмяКолонки] <> Строка2[ИмяКолонки] Тогда
			Возврат Ложь;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

&НаСервере
Процедура ВывестиТаблицуВТабличныйДокумент(ТаблДок, ВыводимаяТЗ, Обл, Колонки, КОМСоединение)
	
	Если ВыводимаяТЗ.Количество() > 0 Тогда
		ТаблДок.Вывести(Обл.ШапкаНачало, 0);
		Для Каждого ИмяКолонки Из Колонки.КлючевыеДляЗаголовков Цикл
			Обл.ШапкаСтолбец.Параметры.ИмяКолонки = ИмяКолонки;
			ТаблДок.Присоединить(Обл.ШапкаСтолбец);
		КонецЦикла;
		Для Каждого ИмяКолонки Из Колонки.Остальные Цикл
			Обл.ШапкаСтолбец.Параметры.ИмяКолонки = ИмяКолонки;
			ТаблДок.Присоединить(Обл.ШапкаСтолбец);
		КонецЦикла;
	КонецЕсли;
	Для Каждого СтрокаТЗ Из ВыводимаяТЗ Цикл
		РезультатСравнения.Вывести(Обл.СтрокаНачало, 1);
		Для Каждого ИмяКолонки Из Колонки.Ключевые Цикл
			Обл.СтрокаСтолбец.Параметры.ЗначениеКолонки = СтрокаТЗ[ИмяКолонки];
			Если Колонки.Ссылочные.Найти(ИмяКолонки) <> Неопределено Тогда
				Обл.СтрокаСтолбец.Параметры.ЗначениеРасшифровкиКолонки = СтрокаТЗ[ИмяКолонки];
			КонецЕсли;
			ТаблДок.Присоединить(Обл.СтрокаСтолбец);
		КонецЦикла;
		Для Каждого ИмяКолонки Из Колонки.Остальные Цикл
			Обл.СтрокаСтолбец.Параметры.ЗначениеКолонки = СтрокаТЗ[ИмяКолонки];
			Если Колонки.Ссылочные.Найти(ИмяКолонки) <> Неопределено Тогда
				Обл.СтрокаСтолбец.Параметры.ЗначениеРасшифровкиКолонки = СтрокаТЗ[ИмяКолонки];
			КонецЕсли;
			ТаблДок.Присоединить(Обл.СтрокаСтолбец);
		КонецЦикла;		
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Процедура ВнешнийЗапросПриИзмененииНаСервере()
	// Вставить содержимое обработчика.
	ТекстЗапросаЭтойБазы = ВнешнийЗапрос.ТекстЗапроса;
	ПараметрыЗапросаЭтойБазы.Очистить();
	Для Каждого СтрокаВЗ из ВнешнийЗапрос.Параметры Цикл 
		СтрокаЭб = ПараметрыЗапросаЭтойБазы.Добавить();
		ЗаполнитьЗначенияСвойств(СтрокаЭБ,СтрокаВЗ);
		МассивТипов = Новый Массив;
		МассивТипов.Добавить(ТипЗнч(СтрокаЭБ.ЗначениеПараметра));
		СтрокаЭБ.ТипПараметра = Новый ОписаниеТипов(МассивТипов);
		Если СтрокаЭБ.ИмяПараметра = "ТекущаяДата" тогда
			 СтрокаЭБ.ЗначениеПараметра = ТекущаяДата();
		КонецЕсли;	
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура ВнешнийЗапросПриИзменении(Элемент)
	ВнешнийЗапросПриИзмененииНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура СохранитьВоВнешнийЗапрос(Команда)
	Если не ЗначениеЗаполнено(ВнешнийЗапрос) тогда
		Предупреждение("Выберите запрос для сохранения");
		Возврат;
	КонецЕсли;	
	СохранитьВоВнешнийЗапросНаСервере();
	Предупреждение("Запрос сохранен");
КонецПроцедуры

&НаСервере
Процедура СохранитьВоВнешнийЗапросНаСервере()
	ОбъектВнешнийЗапрос = ВнешнийЗапрос.Ссылка.ПолучитьОбъект();
	ОбъектВнешнийЗапрос.ТекстЗапроса = ТекстЗапросаЭтойБазы;
	ОбъектВнешнийЗапрос.Параметры.Очистить();
	Для каждого СтрокаЭБ из ПараметрыЗапросаЭтойБазы цикл
		 строкаВЗ = ОбъектВнешнийЗапрос.Параметры.Добавить();
		 ЗаполнитьЗначенияСвойств(СтрокаВЗ,СтрокаЭБ);
	КонецЦикла;
	ОбъектВнешнийЗапрос.Записать();
	
КонецПроцедуры

#КонецОбласти
