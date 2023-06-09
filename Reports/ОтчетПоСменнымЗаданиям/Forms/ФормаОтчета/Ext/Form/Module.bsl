﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
Отчет.Период.Вариант = ВариантСтандартногоПериода.Сегодня;
КонецПроцедуры
                 
&НаСервере
Процедура СформироватьНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблМТК = Макет.ПолучитьОбласть("МТК");	
ОблПЗ = Макет.ПолучитьОбласть("ПЗ");	
ОблКонец = Макет.ПолучитьОбласть("Конец");

ОблШапка.Параметры.ДатаНач = НачалоДня(Отчет.Период.ДатаНачала);
ОблШапка.Параметры.ДатаКон = КонецДня(Отчет.Период.ДатаОкончания);
ОблШапка.Параметры.ВыбИсполнитель = Отчет.Исполнитель;
ОблШапка.Параметры.ВыбРМ = Отчет.РабочееМесто;
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос;

Запрос.Текст = 
"ВЫБРАТЬ
|	ЭтапыПроизводственныхЗаданий.ДатаНачала,
|	ЭтапыПроизводственныхЗаданий.ДатаОкончания,
|	ЭтапыПроизводственныхЗаданий.ПЗ,
|	ЭтапыПроизводственныхЗаданий.ПЗ.ДокументОснование КАК МТК,
|	ЭтапыПроизводственныхЗаданий.Количество
|ИЗ
|	РегистрСведений.ЭтапыПроизводственныхЗаданий КАК ЭтапыПроизводственныхЗаданий
|ГДЕ
|	ЭтапыПроизводственныхЗаданий.ДатаОкончания МЕЖДУ &ДатаНач И &ДатаКон
|	И ЭтапыПроизводственныхЗаданий.РабочееМесто = &РабочееМесто";
	Если Не Отчет.Исполнитель.Пустая() Тогда
	Запрос.Текст = Запрос.Текст + " И ЭтапыПроизводственныхЗаданий.Исполнитель = &Исполнитель";
	Запрос.УстановитьПараметр("Исполнитель",Отчет.Исполнитель);
	КонецЕсли; 	
Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО ЭтапыПроизводственныхЗаданий.ПЗ.НомерОчереди
							  |ИТОГИ ПО МТК";
Запрос.УстановитьПараметр("РабочееМесто",Отчет.РабочееМесто);
Запрос.УстановитьПараметр("ДатаНач",НачалоДня(Отчет.Период.ДатаНачала));
Запрос.УстановитьПараметр("ДатаКон",КонецДня(Отчет.Период.ДатаОкончания));
НомСтр = 0;
КолПриб = 0;
КолПрибУсл = 0;
Результат = Запрос.Выполнить();
ВыборкаМТК = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаМТК.Следующий() Цикл
	ОблМТК.Параметры.МТК = ВыборкаМТК.МТК;
	ОблМТК.Параметры.НомерМТК = ВыборкаМТК.МТК.Номер;
	ОблМТК.Параметры.Спецификация = СокрЛП(ВыборкаМТК.МТК.Номенклатура.Наименование);
	ТабДок.Вывести(ОблМТК);
	ТабДок.НачатьГруппуСтрок("МТК",Истина);
	ВыборкаДетальныеЗаписи = ВыборкаМТК.Выбрать(ОбходРезультатаЗапроса.Прямой);
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		НомСтр = НомСтр + 1;
		ОблПЗ.Параметры.НомСтр = НомСтр;
		ОблПЗ.Параметры.ПЗ = ВыборкаДетальныеЗаписи.ПЗ;
		ОблПЗ.Параметры.НомерПЗ = ВыборкаДетальныеЗаписи.ПЗ.Номер;
		ОблПЗ.Параметры.Количество = ВыборкаДетальныеЗаписи.Количество;
		ОблПЗ.Параметры.ЕдиницаИзмерения = ВыборкаМТК.МТК.Номенклатура.ЕдиницаИзмерения;
		ОблПЗ.Параметры.ВозвратнаяТара = ВыборкаДетальныеЗаписи.ПЗ.ВозвратнаяТара;
		ОблПЗ.Параметры.БарКод = ВыборкаДетальныеЗаписи.ПЗ.БарКод;
		ОблПЗ.Параметры.ДатаНачала = ВыборкаДетальныеЗаписи.ДатаНачала;
		ОблПЗ.Параметры.ДатаОкончания = ВыборкаДетальныеЗаписи.ДатаОкончания;
		ТабДок.Вывести(ОблПЗ);
		КолПриб = КолПриб + ВыборкаДетальныеЗаписи.Количество; 
		КолПрибУсл = КолПрибУсл + ВыборкаДетальныеЗаписи.Количество*ВыборкаДетальныеЗаписи.ПЗ.Изделие.УсловныеПриборы;			
		КонецЦикла;
	ТабДок.ЗакончитьГруппуСтрок();
	КонецЦикла;
ОблКонец.Параметры.КолПриб = КолПриб;
ОблКонец.Параметры.КолПрибУсл = КолПрибУсл;
ТабДок.Вывести(ОблКонец);
ТабДок.ФиксацияСверху = 4;
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
СформироватьНаСервере();
КонецПроцедуры
