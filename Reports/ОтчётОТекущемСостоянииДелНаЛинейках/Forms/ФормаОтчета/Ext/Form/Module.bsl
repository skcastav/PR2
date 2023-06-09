﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
ИспользоватьПараметрФормированияОтчёта = 1;
ГруппироватьПо = 1;
КонецПроцедуры 

&НаКлиенте
Процедура ПриОткрытии(Отказ)
ИспользоватьПараметрФормированияОтчётаПриИзменении(Неопределено);
КонецПроцедуры

&НаКлиенте
Процедура ИспользоватьПараметрФормированияОтчётаПриИзменении(Элемент)
	Если ИспользоватьПараметрФормированияОтчёта = 1 Тогда
	Элементы.СписокЛинеек.Видимость = Истина;
	Элементы.СписокГруппЛинеек.Видимость = Ложь;
	Элементы.СписокПодразделений.Видимость = Ложь;		
	ИначеЕсли ИспользоватьПараметрФормированияОтчёта = 2 Тогда
	Элементы.СписокЛинеек.Видимость = Ложь;
	Элементы.СписокГруппЛинеек.Видимость = Истина;
	Элементы.СписокПодразделений.Видимость = Ложь;
	ИначеЕсли ИспользоватьПараметрФормированияОтчёта = 3 Тогда
	Элементы.СписокЛинеек.Видимость = Ложь;
	Элементы.СписокГруппЛинеек.Видимость = Ложь;
	Элементы.СписокПодразделений.Видимость = Истина;	
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция НаходитсяВЛО(МТК)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ЛьготнаяОчередьСрезПоследних.ПЗ КАК ПЗ
	|ИЗ
	|	РегистрСведений.ЛьготнаяОчередь.СрезПоследних(, Изделие = &Изделие) КАК ЛьготнаяОчередьСрезПоследних
	|ГДЕ
	|	ЛьготнаяОчередьСрезПоследних.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("Изделие",МТК.Номенклатура);
РезультатЗапроса = Запрос.Выполнить();
Возврат(Не РезультатЗапроса.Пустой());
КонецФункции 

&НаСервере
Функция НаходитсяВЛОПоЛинейке(Линейка,Товар)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ЛьготнаяОчередьСрезПоследних.ПЗ КАК ПЗ
	|ИЗ
	|	РегистрСведений.ЛьготнаяОчередь.СрезПоследних(
	|			,
	|			Линейка = &Линейка
	|				И Изделие.Товар = &Товар) КАК ЛьготнаяОчередьСрезПоследних
	|ГДЕ
	|	ЛьготнаяОчередьСрезПоследних.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("Линейка",Линейка);
Запрос.УстановитьПараметр("Товар",Товар);
РезультатЗапроса = Запрос.Выполнить();
Возврат(Не РезультатЗапроса.Пустой());
КонецФункции 

&НаСервере
Функция НаходитсяВРемонте(МТК)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	РемонтнаяКарта.Ссылка
	|ИЗ
	|	Документ.РемонтнаяКарта КАК РемонтнаяКарта
	|ГДЕ
	|	РемонтнаяКарта.Проведен = ЛОЖЬ
	|	И РемонтнаяКарта.ДокументОснование.ДокументОснование = &ДокументОснование";
Запрос.УстановитьПараметр("ДокументОснование",МТК);
РезультатЗапроса = Запрос.Выполнить();
Выборка = РезультатЗапроса.Выбрать();
Возврат(Выборка.Количество());
КонецФункции 
      
&НаСервере
Функция ПолучитьНезапущенноеКоличествоПоЛинейке(Линейка,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПроизводственноеЗадание.Линейка КАК Линейка,
	|	СУММА(ПроизводственноеЗадание.Количество) КАК Количество
	|ИЗ
	|	Документ.ПроизводственноеЗадание КАК ПроизводственноеЗадание
	|ГДЕ
	|	ПроизводственноеЗадание.ДатаЗапуска = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И ПроизводственноеЗадание.Линейка = &Линейка
	|	И ПроизводственноеЗадание.ДокументОснование.Ремонт = ЛОЖЬ";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И ПроизводственноеЗадание.ДокументОснование.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО ПроизводственноеЗадание.Линейка";
Запрос.УстановитьПараметр("Линейка",Линейка);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции 

&НаСервере
Функция ПолучитьНезапущенноеКоличествоПоТовару(Линейка,Товар,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(ПроизводственноеЗадание.Количество) КАК Количество,
	|	ПроизводственноеЗадание.Изделие.Товар КАК ИзделиеТовар
	|ИЗ
	|	Документ.ПроизводственноеЗадание КАК ПроизводственноеЗадание
	|ГДЕ
	|	ПроизводственноеЗадание.ДатаЗапуска = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И ПроизводственноеЗадание.Линейка = &Линейка
	|	И ПроизводственноеЗадание.Изделие.Товар = &Товар
	|	И ПроизводственноеЗадание.ДокументОснование.Ремонт = ЛОЖЬ";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И ПроизводственноеЗадание.ДокументОснование.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО ПроизводственноеЗадание.Изделие.Товар";
Запрос.УстановитьПараметр("Линейка",Линейка);
Запрос.УстановитьПараметр("Товар",Товар);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции

&НаСервере
Функция ПолучитьКоличествоВОжиданииПоЛинейке(Линейка,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МаршрутнаяКарта.Линейка КАК Линейка,
	|	СУММА(МаршрутнаяКарта.Количество) КАК Количество
	|ИЗ
	|	Документ.МаршрутнаяКарта КАК МаршрутнаяКарта
	|ГДЕ
	|	МаршрутнаяКарта.Линейка = &Линейка
	|	И МаршрутнаяКарта.Статус = 0
	|	И МаршрутнаяКарта.Ремонт = ЛОЖЬ";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И МаршрутнаяКарта.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО МаршрутнаяКарта.Линейка";
Запрос.УстановитьПараметр("Линейка",Линейка);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции
 
&НаСервере
Функция ПолучитьКоличествоВОжиданииПоТовару(Линейка,Товар,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(МаршрутнаяКарта.Количество) КАК Количество,
	|	МаршрутнаяКарта.Номенклатура.Товар КАК НоменклатураТовар
	|ИЗ
	|	Документ.МаршрутнаяКарта КАК МаршрутнаяКарта
	|ГДЕ                            
	|	МаршрутнаяКарта.Линейка = &Линейка
	|	И МаршрутнаяКарта.Номенклатура.Товар = &Товар
	|	И МаршрутнаяКарта.Статус = 0
	|	И МаршрутнаяКарта.Ремонт = ЛОЖЬ";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И МаршрутнаяКарта.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО МаршрутнаяКарта.Номенклатура.Товар";
Запрос.УстановитьПараметр("Линейка",Линейка);
Запрос.УстановитьПараметр("Товар",Товар);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции

&НаСервере
Функция ПолучитьКоличествоВОстановкеПоЛинейке(Линейка,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПланыВыпускаОстатки.Линейка КАК Линейка,
	|	СУММА(ПланыВыпускаОстатки.КоличествоОстаток) КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ПланыВыпуска.Остатки(, Линейка = &Линейка) КАК ПланыВыпускаОстатки
	|ГДЕ
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.Статус = 2
	|	И ПланыВыпускаОстатки.МаршрутнаяКарта.Ремонт = ЛОЖЬ"; 
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.МаршрутнаяКарта.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО ПланыВыпускаОстатки.Линейка";
Запрос.УстановитьПараметр("Линейка",Линейка);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.КоличествоОстаток);
    КонецЦикла;
Возврат(0);
КонецФункции 
  
&НаСервере
Функция ПолучитьКоличествоВОстановкеПоТовару(Линейка,Товар,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(ПланыВыпускаОстатки.КоличествоОстаток) КАК КоличествоОстаток,
	|	ПланыВыпускаОстатки.Номенклатура.Товар КАК НоменклатураТовар
	|ИЗ
	|	РегистрНакопления.ПланыВыпуска.Остатки(
	|			,
	|			Линейка = &Линейка
	|				И Номенклатура.Товар = &Товар) КАК ПланыВыпускаОстатки
	|ГДЕ
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.Статус = 2
	|	И ПланыВыпускаОстатки.МаршрутнаяКарта.Ремонт = ЛОЖЬ";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.МаршрутнаяКарта.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО ПланыВыпускаОстатки.Номенклатура.Товар";
Запрос.УстановитьПараметр("Линейка",Линейка);
Запрос.УстановитьПараметр("Товар",Товар);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.КоличествоОстаток);
    КонецЦикла;
Возврат(0);
КонецФункции

&НаСервере
Функция ПолучитьКоличествоВЛОПоЛинейке(Линейка,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос;                          
СписокИзделий = Новый СписокЗначений;

Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ РАЗЛИЧНЫЕ
	|	ЛьготнаяОчередьСрезПоследних.Изделие КАК Изделие
	|ИЗ
	|	РегистрСведений.ЛьготнаяОчередь.СрезПоследних(
	|			,
	|			Линейка = &Линейка) КАК ЛьготнаяОчередьСрезПоследних
	|ГДЕ
	|	ЛьготнаяОчередьСрезПоследних.ДатаОкончания = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)";
Запрос.УстановитьПараметр("Линейка",Линейка);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаИзделия = РезультатЗапроса.Выбрать();
	Пока ВыборкаИзделия.Следующий() Цикл
	СписокИзделий.Добавить(ВыборкаИзделия.Изделие);
	КонецЦикла;
Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(ПроизводственноеЗадание.Количество) КАК Количество,
	|	ПроизводственноеЗадание.Линейка КАК Линейка
	|ИЗ
	|	Документ.ПроизводственноеЗадание КАК ПроизводственноеЗадание
	|ГДЕ
	|	ПроизводственноеЗадание.Линейка = &Линейка
	|	И ПроизводственноеЗадание.ДатаЗапуска = ДАТАВРЕМЯ(1, 1, 1, 0, 0, 0)
	|	И ПроизводственноеЗадание.ДокументОснование.Ремонт = ЛОЖЬ
	|	И ПроизводственноеЗадание.Изделие В(&СписокИзделий)";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И ПроизводственноеЗадание.ДокументОснование.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО ПроизводственноеЗадание.Линейка";
Запрос.УстановитьПараметр("Линейка",Линейка);
Запрос.УстановитьПараметр("СписокИзделий",СписокИзделий);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции
 
&НаСервере
Функция ПолучитьКоличествоВРемонтеПоЛинейке(Линейка,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	РемонтнаяКарта.Линейка КАК Линейка,
	|	СУММА(РемонтнаяКарта.Количество) КАК Количество
	|ИЗ
	|	Документ.РемонтнаяКарта КАК РемонтнаяКарта
	|ГДЕ
	|	РемонтнаяКарта.Проведен = ЛОЖЬ
	|	И РемонтнаяКарта.Линейка = &Линейка";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И РемонтнаяКарта.ДокументОснование.ДокументОснование.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО РемонтнаяКарта.Линейка";
Запрос.УстановитьПараметр("Линейка",Линейка);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции
      
&НаСервере
Функция ПолучитьКоличествоВРемонтеПоТовару(Линейка,Товар,ДатаОтгрузки = Неопределено)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	СУММА(РемонтнаяКарта.Количество) КАК Количество,
	|	РемонтнаяКарта.Товар КАК Товар
	|ИЗ
	|	Документ.РемонтнаяКарта КАК РемонтнаяКарта
	|ГДЕ
	|	РемонтнаяКарта.Проведен = ЛОЖЬ 
	|	И РемонтнаяКарта.Линейка = &Линейка
	|	И РемонтнаяКарта.Товар = &Товар";
	Если ДатаОтгрузки <> Неопределено Тогда
	Запрос.Текст = Запрос.Текст + " И РемонтнаяКарта.ДокументОснование.ДокументОснование.ДатаОтгрузки = &ДатаОтгрузки";
	Запрос.УстановитьПараметр("ДатаОтгрузки",ДатаОтгрузки);
	КонецЕсли;
Запрос.Текст = Запрос.Текст + " СГРУППИРОВАТЬ ПО РемонтнаяКарта.Товар";
Запрос.УстановитьПараметр("Линейка",Линейка);
Запрос.УстановитьПараметр("Товар",Товар);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать();
	Пока ВыборкаЛинейки.Следующий() Цикл
	Возврат(ВыборкаЛинейки.Количество);
    КонецЦикла;
Возврат(0);
КонецФункции

&НаСервере
Процедура СформироватьНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");
ОблСтрока = Макет.ПолучитьОбласть("Строка");
ОблТовар = Макет.ПолучитьОбласть("Товар");
ОблКонец = Макет.ПолучитьОбласть("Конец");

ОблШапка.Параметры.НаДату = ТекущаяДата();
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПланыВыпускаОстатки.Линейка КАК Линейка,
	|	ПланыВыпускаОстатки.Номенклатура.Товар КАК Товар,
	|	ПланыВыпускаОстатки.Номенклатура.Товар.Наименование КАК ТоварНаименование,
	|	ПланыВыпускаОстатки.КоличествоОстаток КАК КоличествоОстаток
	|ИЗ
	|	РегистрНакопления.ПланыВыпуска.Остатки КАК ПланыВыпускаОстатки
	|ГДЕ
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.Статус <> 3
	|	И ПланыВыпускаОстатки.МаршрутнаяКарта.Ремонт = ЛОЖЬ";
	Если ИспользоватьПараметрФормированияОтчёта = 1 Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Линейка В (&СписокЛинеек)";		
	Запрос.УстановитьПараметр("СписокЛинеек",СписокЛинеек);	
	ИначеЕсли ИспользоватьПараметрФормированияОтчёта = 2 Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Линейка В ИЕРАРХИИ(&СписокЛинеек)";		
	Запрос.УстановитьПараметр("СписокЛинеек",СписокГруппЛинеек);			
	Иначе
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Подразделение В(&СписокПодразделений)";		
	Запрос.УстановитьПараметр("СписокПодразделений",СписокПодразделений);	
	КонецЕсли;  
Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО
								|	ПланыВыпускаОстатки.Линейка.Наименование,ТоварНаименование
								|ИТОГИ 	СУММА(КоличествоОстаток) ПО
								|	Линейка,Товар";

КолНезапВсего = 0;
КолВОстановкеВсего = 0;
КолВОжиданииВсего = 0;
КолВЛОВсего = 0;
КолЗапВсего = 0;
КолВРаботеВсего = 0;
КолВРемонтеВсего = 0;
КолДолгВсего = 0;
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЛинейки.Следующий() Цикл
	ОблСтрока.Параметры.Линейка = ВыборкаЛинейки.Линейка;
	ОблСтрока.Параметры.Комментарий = ВыборкаЛинейки.Линейка.Комментарий;
	ОблСтрока.Параметры.Парам = Новый Структура("Линейка",ВыборкаЛинейки.Линейка);
	ОблСтрока.Параметры.КолНезап = ПолучитьНезапущенноеКоличествоПоЛинейке(ВыборкаЛинейки.Линейка);                  
	ОблСтрока.Параметры.КолЗап = ВыборкаЛинейки.КоличествоОстаток - ОблСтрока.Параметры.КолНезап;
	ОблСтрока.Параметры.КолВОстановке = ПолучитьКоличествоВОстановкеПоЛинейке(ВыборкаЛинейки.Линейка);
	ОблСтрока.Параметры.КолВОжидании = ПолучитьКоличествоВОжиданииПоЛинейке(ВыборкаЛинейки.Линейка);
	ОблСтрока.Параметры.КолВЛО = ПолучитьКоличествоВЛОПоЛинейке(ВыборкаЛинейки.Линейка);
	ОблСтрока.Параметры.КолВРемонте = ПолучитьКоличествоВРемонтеПоЛинейке(ВыборкаЛинейки.Линейка);
	ОблСтрока.Параметры.КолВРаботе = ОблСтрока.Параметры.КолЗап - ОблСтрока.Параметры.КолВРемонте;
	ОблСтрока.Параметры.КолДолг = ОблСтрока.Параметры.КолЗап + ОблСтрока.Параметры.КолНезап;
	ТабДок.Вывести(ОблСтрока);             
	КолНезапВсего = КолНезапВсего + ОблСтрока.Параметры.КолНезап;
	КолВОстановкеВсего = КолВОстановкеВсего + ОблСтрока.Параметры.КолВОстановке;
	КолВОжиданииВсего = КолВОжиданииВсего + ОблСтрока.Параметры.КолВОжидании;
	КолВЛОВсего = КолВЛОВсего + ОблСтрока.Параметры.КолВЛО;
	КолЗапВсего = КолЗапВсего + ОблСтрока.Параметры.КолЗап;
	КолВРаботеВсего = КолВРаботеВсего + ОблСтрока.Параметры.КолВРаботе;
	КолВРемонтеВсего = КолВРемонтеВсего + ОблСтрока.Параметры.КолВРемонте;
	КолДолгВсего = КолДолгВсего + ОблСтрока.Параметры.КолДолг;
	ТабДок.НачатьГруппуСтрок("Товар",Ложь);
	ВыборкаТовары = ВыборкаЛинейки.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаТовары.Следующий() Цикл
		ОблТовар.Параметры.ТоварНаименование = СокрЛП(ВыборкаТовары.Товар.Наименование);
		ОблТовар.Параметры.Товар = ВыборкаТовары.Товар;
		ОблТовар.Параметры.Парам = Новый Структура("Линейка,Товар,ДатаОтгрузки",ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,Дата(1,1,1));
		ОблТовар.Параметры.КолНезап = ПолучитьНезапущенноеКоличествоПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар);                  
		ОблТовар.Параметры.КолЗап = ВыборкаТовары.КоличествоОстаток - ОблТовар.Параметры.КолНезап;
		ОблТовар.Параметры.КолВОстановке = ПолучитьКоличествоВОстановкеПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар);
		ОблТовар.Параметры.КолВОжидании = ПолучитьКоличествоВОжиданииПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар);
		ОблТовар.Параметры.КолВЛО = ?(НаходитсяВЛОПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар),ОблТовар.Параметры.КолНезап,0);
		ОблТовар.Параметры.КолВРемонте = ПолучитьКоличествоВРемонтеПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар);
		ОблТовар.Параметры.КолВРаботе = ОблТовар.Параметры.КолЗап - ОблТовар.Параметры.КолВРемонте;
		ОблТовар.Параметры.КолДолг = ОблТовар.Параметры.КолЗап + ОблТовар.Параметры.КолНезап;
		ТабДок.Вывести(ОблТовар);		
		КонецЦикла;
	ТабДок.ЗакончитьГруппуСтрок();
	КонецЦикла;
ОблКонец.Параметры.КолНезапВсего = КолНезапВсего;
ОблКонец.Параметры.КолВОстановкеВсего = КолВОстановкеВсего;
ОблКонец.Параметры.КолВОжиданииВсего = КолВОжиданииВсего;
ОблКонец.Параметры.КолВЛОВсего = КолВЛОВсего;
ОблКонец.Параметры.КолЗапВсего = КолЗапВсего;
ОблКонец.Параметры.КолВРаботеВсего = КолВРаботеВсего;
ОблКонец.Параметры.КолВРемонтеВсего = КолВРемонтеВсего;
ОблКонец.Параметры.КолДолгВсего = КолДолгВсего;
ТабДок.Вывести(ОблКонец);
ТабДок.ФиксацияСверху = 3;
КонецПроцедуры

&НаСервере
Процедура СформироватьВРазрезеДатОтгрузкиНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");
ОблДатаОтгрузки = Макет.ПолучитьОбласть("ДатаОтгрузки");
ОблСтрока = Макет.ПолучитьОбласть("Строка");
ОблТовар = Макет.ПолучитьОбласть("Товар");
ОблКонец = Макет.ПолучитьОбласть("Конец");

ОблШапка.Параметры.НаДату = ТекущаяДата();
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПланыВыпускаОстатки.Линейка КАК Линейка,
	|	ПланыВыпускаОстатки.Номенклатура.Товар КАК Товар,
	|	ПланыВыпускаОстатки.Номенклатура.Товар.Наименование КАК ТоварНаименование,
	|	ПланыВыпускаОстатки.КоличествоОстаток КАК КоличествоОстаток,
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.ДатаОтгрузки КАК ДатаОтгрузки
	|ИЗ
	|	РегистрНакопления.ПланыВыпуска.Остатки КАК ПланыВыпускаОстатки
	|ГДЕ
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.Статус <> 3
	|	И ПланыВыпускаОстатки.МаршрутнаяКарта.Ремонт = ЛОЖЬ";
	Если ИспользоватьПараметрФормированияОтчёта = 1 Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Линейка В (&СписокЛинеек)";		
	Запрос.УстановитьПараметр("СписокЛинеек",СписокЛинеек);	
	ИначеЕсли ИспользоватьПараметрФормированияОтчёта = 2 Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Линейка В ИЕРАРХИИ(&СписокЛинеек)";		
	Запрос.УстановитьПараметр("СписокЛинеек",СписокГруппЛинеек);			
	Иначе
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Подразделение В(&СписокПодразделений)";		
	Запрос.УстановитьПараметр("СписокПодразделений",СписокПодразделений);	
	КонецЕсли;  
Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО
								|	ДатаОтгрузки,ПланыВыпускаОстатки.Линейка.Наименование,ТоварНаименование
								|ИТОГИ 	СУММА(КоличествоОстаток) ПО
								|	ДатаОтгрузки,Линейка,Товар";

КолНезапВсего = 0;
КолВОстановкеВсего = 0;
КолВОжиданииВсего = 0;
КолВЛОВсего = 0;
КолЗапВсего = 0;
КолВРаботеВсего = 0;
КолВРемонтеВсего = 0;
КолДолгВсего = 0;
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДатыОтгрузки = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаДатыОтгрузки.Следующий() Цикл
    ОблДатаОтгрузки.Параметры.ДатаОтгрузки = ВыборкаДатыОтгрузки.ДатаОтгрузки;
	ТабДок.Вывести(ОблДатаОтгрузки);
	ТабДок.НачатьГруппуСтрок("Линейка",Ложь);
	ВыборкаЛинейки = ВыборкаДатыОтгрузки.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаЛинейки.Следующий() Цикл
		ОблСтрока.Параметры.Линейка = ВыборкаЛинейки.Линейка;
		ОблСтрока.Параметры.Комментарий = ВыборкаЛинейки.Линейка.Комментарий;
		ОблСтрока.Параметры.Парам = Новый Структура("Линейка",ВыборкаЛинейки.Линейка);
		ОблСтрока.Параметры.КолНезап = ПолучитьНезапущенноеКоличествоПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);                  
		ОблСтрока.Параметры.КолЗап = ВыборкаЛинейки.КоличествоОстаток - ОблСтрока.Параметры.КолНезап;
		ОблСтрока.Параметры.КолВОстановке = ПолучитьКоличествоВОстановкеПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВОжидании = ПолучитьКоличествоВОжиданииПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВЛО = ПолучитьКоличествоВЛОПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВРемонте = ПолучитьКоличествоВРемонтеПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВРаботе = ОблСтрока.Параметры.КолЗап - ОблСтрока.Параметры.КолВРемонте;
		ОблСтрока.Параметры.КолДолг = ОблСтрока.Параметры.КолЗап + ОблСтрока.Параметры.КолНезап;
		ТабДок.Вывести(ОблСтрока);             
		КолНезапВсего = КолНезапВсего + ОблСтрока.Параметры.КолНезап;
		КолВОстановкеВсего = КолВОстановкеВсего + ОблСтрока.Параметры.КолВОстановке;
		КолВОжиданииВсего = КолВОжиданииВсего + ОблСтрока.Параметры.КолВОжидании;
		КолВЛОВсего = КолВЛОВсего + ОблСтрока.Параметры.КолВЛО;
		КолЗапВсего = КолЗапВсего + ОблСтрока.Параметры.КолЗап;
		КолВРаботеВсего = КолВРаботеВсего + ОблСтрока.Параметры.КолВРаботе;
		КолВРемонтеВсего = КолВРемонтеВсего + ОблСтрока.Параметры.КолВРемонте;
		КолДолгВсего = КолДолгВсего + ОблСтрока.Параметры.КолДолг;
		ТабДок.НачатьГруппуСтрок("Товар",Ложь);
		ВыборкаТовары = ВыборкаЛинейки.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаТовары.Следующий() Цикл
			ОблТовар.Параметры.ТоварНаименование = СокрЛП(ВыборкаТовары.Товар.Наименование);
			ОблТовар.Параметры.Товар = ВыборкаТовары.Товар;
			ОблТовар.Параметры.Парам = Новый Структура("Линейка,Товар,ДатаОтгрузки",ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,Дата(1,1,1));
			ОблТовар.Параметры.КолНезап = ПолучитьНезапущенноеКоличествоПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);                  
			ОблТовар.Параметры.КолЗап = ВыборкаТовары.КоличествоОстаток - ОблТовар.Параметры.КолНезап;
			ОблТовар.Параметры.КолВОстановке = ПолучитьКоличествоВОстановкеПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);
			ОблТовар.Параметры.КолВОжидании = ПолучитьКоличествоВОжиданииПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);
			ОблТовар.Параметры.КолВЛО = ?(НаходитсяВЛОПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар),ОблТовар.Параметры.КолНезап,0);
			ОблТовар.Параметры.КолВРемонте = ПолучитьКоличествоВРемонтеПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);
			ОблТовар.Параметры.КолВРаботе = ОблТовар.Параметры.КолЗап - ОблТовар.Параметры.КолВРемонте;
			ОблТовар.Параметры.КолДолг = ОблТовар.Параметры.КолЗап + ОблТовар.Параметры.КолНезап;
			ТабДок.Вывести(ОблТовар);		
			КонецЦикла;
		ТабДок.ЗакончитьГруппуСтрок();
		КонецЦикла;
	ТабДок.ЗакончитьГруппуСтрок()
	КонецЦикла;
ОблКонец.Параметры.КолНезапВсего = КолНезапВсего;
ОблКонец.Параметры.КолВОстановкеВсего = КолВОстановкеВсего;
ОблКонец.Параметры.КолВОжиданииВсего = КолВОжиданииВсего;
ОблКонец.Параметры.КолВЛОВсего = КолВЛОВсего;
ОблКонец.Параметры.КолЗапВсего = КолЗапВсего;
ОблКонец.Параметры.КолВРаботеВсего = КолВРаботеВсего;
ОблКонец.Параметры.КолВРемонтеВсего = КолВРемонтеВсего;
ОблКонец.Параметры.КолДолгВсего = КолДолгВсего;
ТабДок.Вывести(ОблКонец);
ТабДок.ФиксацияСверху = 3;
КонецПроцедуры

&НаСервере
Процедура СформироватьВРазрезеЛинеекНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");
ОблЛинейка = Макет.ПолучитьОбласть("Линейка");
ОблСтрока = Макет.ПолучитьОбласть("Строка1");
ОблТовар = Макет.ПолучитьОбласть("Товар");
ОблКонец = Макет.ПолучитьОбласть("Конец");

ОблШапка.Параметры.НаДату = ТекущаяДата();
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос; 

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПланыВыпускаОстатки.Линейка КАК Линейка,
	|	ПланыВыпускаОстатки.Номенклатура.Товар КАК Товар,
	|	ПланыВыпускаОстатки.Номенклатура.Товар.Наименование КАК ТоварНаименование,
	|	ПланыВыпускаОстатки.КоличествоОстаток КАК КоличествоОстаток,
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.ДатаОтгрузки КАК ДатаОтгрузки
	|ИЗ
	|	РегистрНакопления.ПланыВыпуска.Остатки КАК ПланыВыпускаОстатки
	|ГДЕ
	|	ПланыВыпускаОстатки.МаршрутнаяКарта.Статус <> 3
	|	И ПланыВыпускаОстатки.МаршрутнаяКарта.Ремонт = ЛОЖЬ";
	Если ИспользоватьПараметрФормированияОтчёта = 1 Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Линейка В (&СписокЛинеек)";		
	Запрос.УстановитьПараметр("СписокЛинеек",СписокЛинеек);	
	ИначеЕсли ИспользоватьПараметрФормированияОтчёта = 2 Тогда
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Линейка В ИЕРАРХИИ(&СписокЛинеек)";		
	Запрос.УстановитьПараметр("СписокЛинеек",СписокГруппЛинеек);			
	Иначе
	Запрос.Текст = Запрос.Текст + " И ПланыВыпускаОстатки.Подразделение В(&СписокПодразделений)";		
	Запрос.УстановитьПараметр("СписокПодразделений",СписокПодразделений);	
	КонецЕсли;  
Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО
								|	ПланыВыпускаОстатки.Линейка.Наименование,ДатаОтгрузки,ТоварНаименование
								|ИТОГИ 	СУММА(КоличествоОстаток) ПО
								|	Линейка,ДатаОтгрузки,Товар";

КолНезапВсего = 0;
КолВОстановкеВсего = 0;
КолВОжиданииВсего = 0;
КолВЛОВсего = 0;
КолЗапВсего = 0;
КолВРаботеВсего = 0;
КолВРемонтеВсего = 0;
КолДолгВсего = 0;
РезультатЗапроса = Запрос.Выполнить();
ВыборкаЛинейки = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЛинейки.Следующий() Цикл
    ОблЛинейка.Параметры.Линейка = ВыборкаЛинейки.Линейка;
	ОблЛинейка.Параметры.Комментарий = ВыборкаЛинейки.Линейка.Комментарий;
	ТабДок.Вывести(ОблЛинейка);
	ТабДок.НачатьГруппуСтрок("Дата отгрузки",Ложь);
	ВыборкаДатыОтгрузки = ВыборкаЛинейки.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаДатыОтгрузки.Следующий() Цикл
		ОблСтрока.Параметры.ДатаОтгрузки = ВыборкаДатыОтгрузки.ДатаОтгрузки;
		ОблСтрока.Параметры.Парам = Новый Структура("Линейка",ВыборкаЛинейки.Линейка);
		ОблСтрока.Параметры.КолНезап = ПолучитьНезапущенноеКоличествоПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);                  
		ОблСтрока.Параметры.КолЗап = ВыборкаДатыОтгрузки.КоличествоОстаток - ОблСтрока.Параметры.КолНезап;
		ОблСтрока.Параметры.КолВОстановке = ПолучитьКоличествоВОстановкеПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВОжидании = ПолучитьКоличествоВОжиданииПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВЛО = ПолучитьКоличествоВЛОПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВРемонте = ПолучитьКоличествоВРемонтеПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаДатыОтгрузки.ДатаОтгрузки);
		ОблСтрока.Параметры.КолВРаботе = ОблСтрока.Параметры.КолЗап - ОблСтрока.Параметры.КолВРемонте;
		ОблСтрока.Параметры.КолДолг = ОблСтрока.Параметры.КолЗап + ОблСтрока.Параметры.КолНезап;
		ТабДок.Вывести(ОблСтрока);             
		КолНезапВсего = КолНезапВсего + ОблСтрока.Параметры.КолНезап;
		КолВОстановкеВсего = КолВОстановкеВсего + ОблСтрока.Параметры.КолВОстановке;
		КолВОжиданииВсего = КолВОжиданииВсего + ОблСтрока.Параметры.КолВОжидании;
		КолВЛОВсего = КолВЛОВсего + ОблСтрока.Параметры.КолВЛО;
		КолЗапВсего = КолЗапВсего + ОблСтрока.Параметры.КолЗап;
		КолВРаботеВсего = КолВРаботеВсего + ОблСтрока.Параметры.КолВРаботе;
		КолВРемонтеВсего = КолВРемонтеВсего + ОблСтрока.Параметры.КолВРемонте;
		КолДолгВсего = КолДолгВсего + ОблСтрока.Параметры.КолДолг;
		ТабДок.НачатьГруппуСтрок("Товар",Ложь);
		ВыборкаТовары = ВыборкаДатыОтгрузки.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаТовары.Следующий() Цикл
			ОблТовар.Параметры.ТоварНаименование = СокрЛП(ВыборкаТовары.Товар.Наименование);
			ОблТовар.Параметры.Товар = ВыборкаТовары.Товар;
			ОблТовар.Параметры.Парам = Новый Структура("Линейка,Товар,ДатаОтгрузки",ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,Дата(1,1,1));
			ОблТовар.Параметры.КолНезап = ПолучитьНезапущенноеКоличествоПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);                  
			ОблТовар.Параметры.КолЗап = ВыборкаТовары.КоличествоОстаток - ОблТовар.Параметры.КолНезап;
			ОблТовар.Параметры.КолВОстановке = ПолучитьКоличествоВОстановкеПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);
			ОблТовар.Параметры.КолВОжидании = ПолучитьКоличествоВОжиданииПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);
			ОблТовар.Параметры.КолВЛО = ?(НаходитсяВЛОПоЛинейке(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар),ОблТовар.Параметры.КолНезап,0);
			ОблТовар.Параметры.КолВРемонте = ПолучитьКоличествоВРемонтеПоТовару(ВыборкаЛинейки.Линейка,ВыборкаТовары.Товар,ВыборкаДатыОтгрузки.ДатаОтгрузки);
			ОблТовар.Параметры.КолВРаботе = ОблТовар.Параметры.КолЗап - ОблТовар.Параметры.КолВРемонте;
			ОблТовар.Параметры.КолДолг = ОблТовар.Параметры.КолЗап + ОблТовар.Параметры.КолНезап;
			ТабДок.Вывести(ОблТовар);		
			КонецЦикла;
		ТабДок.ЗакончитьГруппуСтрок();
		КонецЦикла;
	ТабДок.ЗакончитьГруппуСтрок()
	КонецЦикла;
ОблКонец.Параметры.КолНезапВсего = КолНезапВсего;
ОблКонец.Параметры.КолВОстановкеВсего = КолВОстановкеВсего;
ОблКонец.Параметры.КолВОжиданииВсего = КолВОжиданииВсего;
ОблКонец.Параметры.КолВЛОВсего = КолВЛОВсего;
ОблКонец.Параметры.КолЗапВсего = КолЗапВсего;
ОблКонец.Параметры.КолВРаботеВсего = КолВРаботеВсего;
ОблКонец.Параметры.КолВРемонтеВсего = КолВРемонтеВсего;
ОблКонец.Параметры.КолДолгВсего = КолДолгВсего;
ТабДок.Вывести(ОблКонец);
ТабДок.ФиксацияСверху = 3;
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
Состояние("Обработка...",,"Формирование таблицы отчёта...");
	Если ВРазрезеДатОбещаннойОтгрузки Тогда
		Если ГруппироватьПо = 1 Тогда
		СформироватьВРазрезеЛинеекНаСервере();		
		Иначе	
		СформироватьВРазрезеДатОтгрузкиНаСервере();		
		КонецЕсли;	
	Иначе	
	СформироватьНаСервере();	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ТабДокОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
СтандартнаяОбработка = Ложь;
	Если Найти(Элемент.ТекущаяОбласть.Имя,":") > 0 Тогда
	ИмяЯчейки = СокрЛП(Лев(Элемент.ТекущаяОбласть.Имя,Найти(Элемент.ТекущаяОбласть.Имя,":")-1));	
	Иначе	
	ИмяЯчейки = Элемент.ТекущаяОбласть.Имя;	
	КонецЕсли; 
ИмяКолонки = СокрЛП(Сред(ИмяЯчейки,Найти(ИмяЯчейки,"C")));
НомерКолонки = Число(Сред(ИмяКолонки,2));
	Если НомерКолонки = 1 Тогда	
		Если ТипЗнч(Расшифровка) = Тип("СправочникСсылка.Линейки") Тогда	
		ОткрытьФорму("Отчет.Визуализация.Форма.ФормаОтчета",Новый Структура("Линейка",Расшифровка));
		КонецЕсли;
	ИначеЕсли НомерКолонки = 2 Тогда 	
	ИмяОтчета = "ОтчётПоМТКСКД";
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СформироватьПриОткрытии",Истина);
	ПараметрыФормы.Вставить("ПользовательскиеНастройки",ОбщийМодульВызовСервера.ЗаполнитьПользовательскиеНастройкиОтчетаСКД(ИмяОтчета,Неопределено,Неопределено,Новый Структура("Линейка",Расшифровка),"ВОстановке"));
	ПараметрыФормы.Вставить("КлючВарианта","ВОстановке"); 
	ОткрытьФорму("Отчет." + ИмяОтчета + ".Форма", ПараметрыФормы);
	ИначеЕсли НомерКолонки = 5 Тогда 	
	ОткрытьФорму("Отчет.ОтчетПоТекущейЛьготнойОчередиУправленческий.Форма",Новый Структура("Линейка",Расшифровка));
	ИначеЕсли НомерКолонки = 7 Тогда
	ОткрытьФорму("Отчет.Визуализация.Форма.ФормаОтчета",Расшифровка);
	ИначеЕсли НомерКолонки = 8 Тогда 	
	ИмяОтчета = "ОтчётПоРемонтуСКД";
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СформироватьПриОткрытии",Истина);
	ПараметрыФормы.Вставить("ПользовательскиеНастройки",ОбщийМодульВызовСервера.ЗаполнитьПользовательскиеНастройкиОтчетаСКД(ИмяОтчета,Неопределено,Неопределено,Новый Структура("Линейка,Проведен",Расшифровка,Ложь),"ТекущийРемонт"));
	ПараметрыФормы.Вставить("КлючВарианта","ТекущийРемонт"); 
	ОткрытьФорму("Отчет." + ИмяОтчета + ".Форма", ПараметрыФормы);	
	КонецЕсли; 
КонецПроцедуры
