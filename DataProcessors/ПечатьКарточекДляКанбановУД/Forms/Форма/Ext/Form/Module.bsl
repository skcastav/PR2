﻿
&НаСервере
Процедура ПечатьКарточекНаСервере()
ТабДок.Очистить();
	Если Объект.МестоХраненияПотребитель.Пустая() Тогда
	Макет = ПолучитьОбщийМакет("QRКодКанбан5");
	Иначе
	Макет = ПолучитьОбщийМакет("QRКодКанбан7");
	КонецЕсли;
ОблQRКод = Макет.ПолучитьОбласть("QRКод|Секция");
	Для каждого ТЧ Из Объект.ТаблицаКанбанов Цикл
		Если ТЧ.Пометка Тогда
			Для к = 1 По ТЧ.КоличествоЯчеек Цикл
				Если Объект.МестоХраненияПотребитель.Пустая() Тогда
				QRCode = "5;"+ЗначениеВСтрокуВнутр(Объект.Линейка)+";"+ЗначениеВСтрокуВнутр(ТЧ.Канбан)+";"+СтрЗаменить(Строка(ТЧ.Количество),Символы.НПП,"")+";"+к;
				Иначе	
				QRCode = "7;"+ЗначениеВСтрокуВнутр(Объект.Линейка)+";"+ЗначениеВСтрокуВнутр(Объект.МестоХраненияПотребитель)+";"+ЗначениеВСтрокуВнутр(ТЧ.Канбан)+";"+СтрЗаменить(Строка(ТЧ.Количество),Символы.НПП,"")+";"+к;				
				ОблQRКод.Параметры.МестоХранения = СокрЛП(Объект.МестоХраненияПотребитель.Наименование);
				КонецЕсли; 
			ДанныеQRКода = УправлениеПечатью.ДанныеQRКода(QRCode, 0, 100);	
				Если ТипЗнч(ДанныеQRКода) = Тип("ДвоичныеДанные") Тогда
				КартинкаQRКода = Новый Картинка(ДанныеQRКода);
				ОблQRКод.Рисунки.QRCode.Картинка = КартинкаQRКода;
				Иначе
				Сообщить("Не удалось сформировать QR-код!");
				КонецЕсли;
			ОблQRКод.Параметры.Линейка = СокрЛП(Объект.Линейка.Наименование);
			ОблQRКод.Параметры.Наименование = СокрЛП(ТЧ.Канбан.Наименование);
			ОблQRКод.Параметры.Количество = ТЧ.Количество; 
			ОблQRКод.Параметры.ЕдИзм = СокрЛП(ТЧ.Канбан.ЕдиницаИзмерения.Наименование);
			ОблQRКод.Параметры.НомерЯчейки = к;
			ТабДок.Вывести(ОблQRКод);
 			ТабДок.Присоединить(ОблQRКод);  
			КонецЦикла;
		КонецЕсли; 
	КонецЦикла; 
ТабДок.РазмерСтраницы = "A4";
ТабДок.ПолеСлева = 0;
ТабДок.ПолеСверху = 0;
ТабДок.ПолеСнизу = 0;
ТабДок.ПолеСправа = 0;
ТабДок.РазмерКолонтитулаСверху = 0;
ТабДок.РазмерКолонтитулаСнизу = 0;
КонецПроцедуры

&НаКлиенте
Процедура ПечатьКарточек(Команда)
ПечатьКарточекНаСервере();
КонецПроцедуры

&НаСервере
Процедура ДобавитьИзГруппыНаСервере(ВыбГруппа)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.ЭтоГруппа = ЛОЖЬ
	|	И Номенклатура.Ссылка В ИЕРАРХИИ(&ГруппаНоменклатуры)";
	Если СписокВидовКанбанов.Количество() > 0 Тогда
	Запрос.Текст = Запрос.Текст + " И Номенклатура.Канбан В(&СписокВидовКанбанов)";
	Запрос.УстановитьПараметр("СписокВидовКанбанов", СписокВидовКанбанов);
	Иначе
	Запрос.Текст = Запрос.Текст + " И Номенклатура.Канбан <> &ПустойКанбан";
	Запрос.УстановитьПараметр("ПустойКанбан", Справочники.ВидыКанбанов.ПустаяСсылка());
	КонецЕсли;  
Запрос.УстановитьПараметр("ГруппаНоменклатуры", ВыбГруппа);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	ТЧ = Объект.ТаблицаКанбанов.Добавить();
	ТЧ.Канбан = ВыборкаДетальныеЗаписи.Ссылка;
	ТЧ.КоличествоЯчеек = ВыборкаДетальныеЗаписи.Ссылка.КолКанбан;
	ТЧ.Количество = ВыборкаДетальныеЗаписи.Ссылка.КолВКанбане;
	КонецЦикла;
Объект.ТаблицаКанбанов.Сортировать("Канбан");
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьИзГруппы(Команда)
	Если Объект.ТаблицаКанбанов.Количество() > 0 Тогда
		Если Вопрос("Таблица канбанов не пустая! Очистить?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
		Объект.ТаблицаКанбанов.Очистить();
		КонецЕсли;
	КонецЕсли; 
ВыбГруппа = Неопределено;
Результат = ОткрытьФормуМодально("Справочник.Номенклатура.ФормаВыбораГруппы");
	Если Результат <> Неопределено Тогда
	ДобавитьИзГруппыНаСервере(Результат);
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Процедура ДобавитьПоВидамКанбановНаСервере()
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	Номенклатура.Ссылка
	|ИЗ
	|	Справочник.Номенклатура КАК Номенклатура
	|ГДЕ
	|	Номенклатура.Канбан В ИЕРАРХИИ(&СписокВидовКанбанов)";
Запрос.УстановитьПараметр("СписокВидовКанбанов", СписокВидовКанбанов);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	ТЧ = Объект.ТаблицаКанбанов.Добавить();
	ТЧ.Канбан = ВыборкаДетальныеЗаписи.Ссылка;
	ТЧ.КоличествоЯчеек = ВыборкаДетальныеЗаписи.Ссылка.КолКанбан;
	ТЧ.Количество = ВыборкаДетальныеЗаписи.Ссылка.КолВКанбане;
	КонецЦикла;
Объект.ТаблицаКанбанов.Сортировать("Канбан");
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьПоВидамКанбанов(Команда)
	Если Объект.ТаблицаКанбанов.Количество() > 0 Тогда
		Если Вопрос("Таблица канбанов не пустая! Очистить?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
		Объект.ТаблицаКанбанов.Очистить();
		КонецЕсли;
	КонецЕсли;
ДобавитьПоВидамКанбановНаСервере();
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьВсе(Команда)
	Для каждого ТЧ Из Объект.ТаблицаКанбанов Цикл		
	ТЧ.Пометка = Истина;
	КонецЦикла; 
КонецПроцедуры

&НаКлиенте
Процедура ОтменитьВсе(Команда)
	Для каждого ТЧ Из Объект.ТаблицаКанбанов Цикл		
	ТЧ.Пометка = Ложь;
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура ДобавитьСтрокуНоменклатуры(Наименование,МестоХранения,Количество)
Спецификация = Справочники.Номенклатура.НайтиПоНаименованию(Наименование,Истина);
	Если Не Спецификация.Пустая() Тогда
	ТЧ = Объект.ТаблицаКанбанов.Добавить();
	ТЧ.Пометка = Истина;
	ТЧ.МестоХраненияПотребитель = МестоХранения;
	ТЧ.Канбан = Спецификация;
	ТЧ.КоличествоЯчеек = Спецификация.КолКанбан;	
	ТЧ.Количество = Количество;
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьМестоХранения(Наименование)
Возврат(Справочники.МестаХранения.НайтиПоНаименованию(Наименование,Истина));
КонецФункции
