﻿
&НаСервере
Процедура СформироватьНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблРМ = Макет.ПолучитьОбласть("РМ");
ОблИсполнитель = Макет.ПолучитьОбласть("Исполнитель");
ОблИзделие = Макет.ПолучитьОбласть("Изделие");

ОблШапка.Параметры.ДатаНач = Формат(Отчет.Период.ДатаНачала,"ДФ=dd.MM.yyyy");
ОблШапка.Параметры.ДатаКон = Формат(Отчет.Период.ДатаОкончания,"ДФ=dd.MM.yyyy");
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЭтапыПроизводственныхЗаданий.РабочееМесто КАК РабочееМесто,
	|	ЭтапыПроизводственныхЗаданий.Исполнитель КАК Исполнитель,
	|	ЭтапыПроизводственныхЗаданий.ДатаОкончания КАК ДатаОкончания,
	|	ЭтапыПроизводственныхЗаданий.Изделие КАК Изделие,
	|	ЭтапыПроизводственныхЗаданий.Количество КАК Количество
	|ИЗ
	|	РегистрСведений.ЭтапыПроизводственныхЗаданий КАК ЭтапыПроизводственныхЗаданий
	|ГДЕ
	|	ЭтапыПроизводственныхЗаданий.ДатаОкончания МЕЖДУ &ДатаНач И &ДатаКон";
	Если Не Исполнитель.Пустая() Тогда
	Запрос.Текст = Запрос.Текст + " И ЭтапыПроизводственныхЗаданий.Исполнитель = &Исполнитель";
	Запрос.УстановитьПараметр("Исполнитель",Исполнитель);	
	КонецЕсли;
		Если СписокРМ.Количество() > 0 Тогда
		Запрос.Текст = Запрос.Текст + " И ЭтапыПроизводственныхЗаданий.РабочееМесто В(&СписокРМ)";
		Запрос.УстановитьПараметр("СписокРМ",СписокРМ);
		КонецЕсли; 
Запрос.Текст = Запрос.Текст + "	УПОРЯДОЧИТЬ ПО
								|	РабочееМесто,
								|	Исполнитель,
								|	Изделие
								|ИТОГИ
								|	СУММА(Количество)
								|ПО
								|	РабочееМесто,
								|	Исполнитель,
								|	Изделие";
Запрос.УстановитьПараметр("ДатаНач",НачалоДня(Отчет.Период.ДатаНачала));
Запрос.УстановитьПараметр("ДатаКон",КонецДня(Отчет.Период.ДатаОкончания));
Результат = Запрос.Выполнить();
ВыборкаРМ = Результат.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаРМ.Следующий() Цикл
	ОблРМ.Параметры.РМ = ВыборкаРМ.РабочееМесто;
	ОблРМ.Параметры.Кол = ВыборкаРМ.Количество;
	ТабДок.Вывести(ОблРМ);
	ВыборкаИсполнитель = ВыборкаРМ.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаИсполнитель.Следующий() Цикл
		ОблИсполнитель.Параметры.Исполнитель = СокрЛП(ВыборкаИсполнитель.Исполнитель.Наименование);
		ОблИсполнитель.Параметры.Кол = ВыборкаИсполнитель.Количество;
		ТабДок.Вывести(ОблИсполнитель);
		ВыборкаИзделие = ВыборкаИсполнитель.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаИзделие.Следующий() Цикл
			ОблИзделие.Параметры.Изделие = ВыборкаИзделие.Изделие;
			ОблИзделие.Параметры.Кол = ВыборкаИзделие.Количество;
			ТабДок.Вывести(ОблИзделие);
			КонецЦикла;	
		КонецЦикла;	
	КонецЦикла;
ТабДок.ФиксацияСверху = 3;
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
СформироватьНаСервере();
КонецПроцедуры

&НаСервере
Функция НастройкиНаСервере()
Настройки = Новый Структура("СписокРМ",СписокРМ);
Возврат(Новый Структура("КлючНазначенияИспользования,Настройки","ОтчетПоВыработкеНаРабочемМесте",Настройки));
КонецФункции

&НаКлиенте
Процедура Настройки(Команда)
Результат = ОткрытьФормуМодально("ОбщаяФорма.НастройкиФорм",НастройкиНаСервере());
	Если Результат <> Неопределено Тогда	
	СписокРМ = Результат.СписокРМ;	
	КонецЕсли;
КонецПроцедуры
