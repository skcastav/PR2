﻿
&НаСервере
Процедура СформироватьНаСервере(МПЗ = Неопределено,ТД = Неопределено)
	Если ТД = Неопределено Тогда
	ТабДок.Очистить();
	ТД = ТабДок;
	КонецЕсли; 
ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет"); 

ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблМПЗ = Макет.ПолучитьОбласть("МПЗ");	
ОблКонец = Макет.ПолучитьОбласть("Конец");	

ОблШапка.Параметры.ДатаНач = Отчет.Период.ДатаНачала;
ОблШапка.Параметры.ДатаКон = Отчет.Период.ДатаОкончания;
ОблШапка.Параметры.Подразделение = Отчет.Подразделение;
	Если ПоКанбанам = 1 Тогда
	ОблШапка.Параметры.ВидПростоя = "Время нахождения в ЛО";
	Иначе
	ОблШапка.Параметры.ВидПростоя = "Время простоя линейки";
	КонецЕсли;
ТД.Вывести(ОблШапка);

Запрос = Новый Запрос;
ЗапросПростой = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОборотКанбанов.МестоХранения КАК МестоХранения,
	|	ОборотКанбанов.МПЗ КАК МПЗ,
	|	ОборотКанбанов.Период КАК Период,
	|	ОборотКанбанов.ДатаПринятия КАК ДатаПринятия,
	|	ОборотКанбанов.ДатаПередачи КАК ДатаПередачи,
	|	ОборотКанбанов.ДатаОкончания КАК ДатаОкончания,
	|	ОборотКанбанов.МПЗ.Наименование КАК Наименование
	|ИЗ
	|	РегистрСведений.ОборотКанбанов КАК ОборотКанбанов";
	Если ПоДатам = 1 Тогда
	Запрос.Текст = Запрос.Текст + " ГДЕ ОборотКанбанов.Период МЕЖДУ &ДатаНач И &ДатаКон";
	Иначе
	Запрос.Текст = Запрос.Текст + " ГДЕ ОборотКанбанов.ДатаОкончания МЕЖДУ &ДатаНач И &ДатаКон";
	КонецЕсли; 
Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.Подразделение = &Подразделение";
	Если СписокМестХранения.Количество() > 0 Тогда
	Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.МестоХранения В(&СписокМестХранения)";
	Запрос.УстановитьПараметр("СписокМестХранения", СписокМестХранения);
	КонецЕсли;
		Если МПЗ <> Неопределено Тогда	
		Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.МПЗ = &МПЗ";
		Запрос.УстановитьПараметр("МПЗ", МПЗ);		
		КонецЕсли; 
			Если Показывать = 1 Тогда	
			Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.ДатаОкончания <> ДАТАВРЕМЯ(1,1,1,0,0,0)"; 
			ИначеЕсли Показывать = 2 Тогда	
			Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.ДатаОкончания = ДАТАВРЕМЯ(1,1,1,0,0,0)"; 
			КонецЕсли;
				Если СортироватьПо = 1 Тогда
				Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО МестоХранения";
				Иначе	
				Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО Наименование";		
				КонецЕсли;
Запрос.УстановитьПараметр("ДатаНач", Отчет.Период.ДатаНачала);
Запрос.УстановитьПараметр("ДатаКон", Отчет.Период.ДатаОкончания);
Запрос.УстановитьПараметр("Подразделение", Отчет.Подразделение);
ВремяПростояИтого = 0;  
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл 
		Если ПоКанбанам = 1 Тогда
			Если ТипЗнч(ВыборкаДетальныеЗаписи.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если Не ВыборкаДетальныеЗаписи.МПЗ.Канбан.РезервироватьВПроизводстве Тогда
				Продолжить;
				КонецЕсли;			
			КонецЕсли; 
		Иначе
			Если ТипЗнч(ВыборкаДетальныеЗаписи.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если ВыборкаДетальныеЗаписи.МПЗ.Канбан.РезервироватьВПроизводстве Тогда
				Продолжить;
				КонецЕсли;			
			КонецЕсли; 
		КонецЕсли;
	ОблМПЗ.Параметры.МестоХранения = ВыборкаДетальныеЗаписи.МестоХранения;
	ОблМПЗ.Параметры.МПЗ = ВыборкаДетальныеЗаписи.МПЗ;
	ОблМПЗ.Параметры.ДатаОсвобождения = ВыборкаДетальныеЗаписи.Период;
	ОблМПЗ.Параметры.ДатаПринятия = ВыборкаДетальныеЗаписи.ДатаПринятия;
	ОблМПЗ.Параметры.ДатаПередачи = ВыборкаДетальныеЗаписи.ДатаПередачи;
	ОблМПЗ.Параметры.ДатаПоступления = ВыборкаДетальныеЗаписи.ДатаОкончания;
	ОблМПЗ.Параметры.КоличествоОстаток = ОбщийМодульВызовСервера.ПолучитьОстатокПоМестуХранения(ВыборкаДетальныеЗаписи.МестоХранения,ВыборкаДетальныеЗаписи.МПЗ,ВыборкаДетальныеЗаписи.Период);
		Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаПринятия) Тогда
		ОблМПЗ.Параметры.ВремяДоПринятия = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.Период,ВыборкаДетальныеЗаписи.ДатаПринятия,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
		Иначе
		ОблМПЗ.Параметры.ВремяДоПринятия = 0;
		КонецЕсли;	
			Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) и ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаПринятия) Тогда
			ОблМПЗ.Параметры.ВремяИзготовления = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.ДатаПринятия,ВыборкаДетальныеЗаписи.ДатаОкончания,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
			Иначе	
			ОблМПЗ.Параметры.ВремяИзготовления = 0;
			КонецЕсли;
				Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) Тогда
				ОблМПЗ.Параметры.ВремяОборота = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.Период,ВыборкаДетальныеЗаписи.ДатаОкончания,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
				Иначе	
				ОблМПЗ.Параметры.ВремяОборота = 0;
				КонецЕсли; 
					Если ПоКанбанам = 1 Тогда
					ЗапросПростой.Текст = 
						"ВЫБРАТЬ
						|	ЛьготнаяОчередь.Период,
						|	ЛьготнаяОчередь.ДатаОкончания
						|ИЗ
						|	РегистрСведений.ЛьготнаяОчередь КАК ЛьготнаяОчередь
						|ГДЕ
						|	ЛьготнаяОчередь.Период МЕЖДУ &ДатаНач И &ДатаКон
						|	И ЛьготнаяОчередь.Линейка.МестоХраненияКанбанов = &МестоХранения
						|	И ЛьготнаяОчередь.НормаРасходов.Элемент = &МПЗ";	
					ЗапросПростой.УстановитьПараметр("ДатаНач", ВыборкаДетальныеЗаписи.Период);
						Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) Тогда
						ЗапросПростой.УстановитьПараметр("ДатаКон", ВыборкаДетальныеЗаписи.ДатаОкончания);
						Иначе	
						ЗапросПростой.УстановитьПараметр("ДатаКон", ТекущаяДата());
						КонецЕсли;
					ЗапросПростой.УстановитьПараметр("МестоХранения", ВыборкаДетальныеЗаписи.МестоХранения);
					ЗапросПростой.УстановитьПараметр("МПЗ", ВыборкаДетальныеЗаписи.МПЗ);
					РезультатЗапросаПростой = ЗапросПростой.Выполнить();
					ВыборкаПростой = РезультатЗапросаПростой.Выбрать();
						Если ВыборкаПростой.Количество() > 0 Тогда
						ДатаНачЛО = ТекущаяДата();
						ДатаКонЛО = Дата(1,1,1);
							Пока ВыборкаПростой.Следующий() Цикл
							ДатаНачЛО = Мин(ДатаНачЛО,ВыборкаПростой.Период);
								Если ЗначениеЗаполнено(ВыборкаПростой.ДатаОкончания) Тогда
								ДатаКонЛО = Макс(ДатаКонЛО,ВыборкаПростой.ДатаОкончания);
								Иначе
								ДатаКонЛО = Макс(ДатаКонЛО,ТекущаяДата());
								КонецЕсли;	
							КонецЦикла;					
						ВремяПростоя = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ДатаНачЛО,ДатаКонЛО,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);					
						ВремяПростояИтого = ВремяПростояИтого + ВремяПростоя;
						Иначе	
						ВремяПростоя = 0;
						КонецЕсли;
					ОблМПЗ.Параметры.ВремяПростоя = ВремяПростоя;
					Иначе	
					ЗапросПростой.Текст = 
						"ВЫБРАТЬ
						|	ПростойЛинейки.Период,
						|	ПростойЛинейки.Окончание
						|ИЗ
						|	РегистрСведений.ПростойЛинейки КАК ПростойЛинейки
						|ГДЕ
						|	ПростойЛинейки.Период МЕЖДУ &ДатаНач И &ДатаКон
						|	И ПростойЛинейки.Линейка.МестоХраненияКанбанов = &МестоХранения
						|	И ПростойЛинейки.Причина = &Причина";
					ЗапросПростой.УстановитьПараметр("ДатаНач", ВыборкаДетальныеЗаписи.Период);
					ЗапросПростой.УстановитьПараметр("ДатаКон", ВыборкаДетальныеЗаписи.Период+10); // прибавим 10 секунд для верности
					ЗапросПростой.УстановитьПараметр("МестоХранения", ВыборкаДетальныеЗаписи.МестоХранения);
					ЗапросПростой.УстановитьПараметр("Причина", ВыборкаДетальныеЗаписи.МПЗ);
					РезультатЗапросаПростой = ЗапросПростой.Выполнить();
					ВыборкаПростой = РезультатЗапросаПростой.Выбрать();
						Если ВыборкаПростой.Следующий() Тогда
						ОблМПЗ.Параметры.ВремяПростоя = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаПростой.Период,ВыборкаПростой.Окончание,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
						Иначе
						ОблМПЗ.Параметры.ВремяПростоя = 0;
						КонецЕсли;		
					КонецЕсли; 
	ЯчейкиКомплектации = ОбщийМодульРаботаСРегистрами.ПолучитьЯчейкуКомплектацииПоМестуХранения(ВыборкаДетальныеЗаписи.МестоХранения,ВыборкаДетальныеЗаписи.МПЗ);
	ОблМПЗ.Параметры.КоличествоВЯчейке = ЯчейкиКомплектации.КоличествоВЯчейке;
	ТД.Вывести(ОблМПЗ);	
	КонецЦикла;
ТД.Вывести(ОблКонец); 
ТД.ФиксацияСверху = 3;
КонецПроцедуры

&НаСервере
Процедура СформироватьПоМестамХраненияНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("ПоМестамХранения"); 
ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблМПЗ = Макет.ПолучитьОбласть("МПЗ");	
ОблКонец = Макет.ПолучитьОбласть("Конец");	

ОблШапка.Параметры.ДатаНач = Отчет.Период.ДатаНачала;
ОблШапка.Параметры.ДатаКон = Отчет.Период.ДатаОкончания;
ОблШапка.Параметры.Подразделение = Отчет.Подразделение;
	Если ПоКанбанам = 1 Тогда
	ОблШапка.Параметры.ВидПростоя = "Время нахождения в ЛО";
	Иначе
	ОблШапка.Параметры.ВидПростоя = "Время простоя линейки";
	КонецЕсли;
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос;
ЗапросПростой = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОборотКанбанов.МестоХранения КАК МестоХранения,
	|	ОборотКанбанов.МПЗ КАК МПЗ,
	|	ОборотКанбанов.Период,
	|	ОборотКанбанов.ДатаПринятия,
	|	ОборотКанбанов.ДатаПередачи,
	|	ОборотКанбанов.ДатаОкончания,
	|	ОборотКанбанов.МПЗ.Наименование КАК Наименование
	|ИЗ
	|	РегистрСведений.ОборотКанбанов КАК ОборотКанбанов
	|ГДЕ
	|	ОборотКанбанов.Период МЕЖДУ &ДатаНач И &ДатаКон
	|	И ОборотКанбанов.Подразделение = &Подразделение";
Запрос.УстановитьПараметр("ДатаНач", Отчет.Период.ДатаНачала);
Запрос.УстановитьПараметр("ДатаКон", Отчет.Период.ДатаОкончания);
Запрос.УстановитьПараметр("Подразделение", Отчет.Подразделение);
	Если СписокМестХранения.Количество() > 0 Тогда
	Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.МестоХранения В(&СписокМестХранения)";
	Запрос.УстановитьПараметр("СписокМестХранения", СписокМестХранения);
	КонецЕсли;
		Если Канбан <> Неопределено Тогда	
		Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.МПЗ = &МПЗ";
		Запрос.УстановитьПараметр("МПЗ", Канбан);		
		КонецЕсли;
			Если Показывать = 1 Тогда	
			Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.ДатаОкончания <> ДАТАВРЕМЯ(1,1,1,0,0,0)"; 
			ИначеЕсли Показывать = 2 Тогда	
			Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.ДатаОкончания = ДАТАВРЕМЯ(1,1,1,0,0,0)"; 
			КонецЕсли;
				Если СортироватьПо = 1 Тогда
				Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО МестоХранения";
				Иначе	
				Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО Наименование";		
				КонецЕсли;
Запрос.Текст = Запрос.Текст + " ИТОГИ ПО МестоХранения,МПЗ";  
РезультатЗапроса = Запрос.Выполнить();
КоличествоОборотовИтого = 0;
ВыборкаЛинейка = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаЛинейка.Следующий() Цикл
	ВыборкаМПЗ = ВыборкаЛинейка.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаМПЗ.Следующий() Цикл
			Если ПоКанбанам = 1 Тогда
				Если ТипЗнч(ВыборкаМПЗ.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
					Если Не ВыборкаМПЗ.МПЗ.Канбан.РезервироватьВПроизводстве Тогда
					Продолжить;
					КонецЕсли;			
				КонецЕсли; 
			Иначе
				Если ТипЗнч(ВыборкаМПЗ.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
					Если ВыборкаМПЗ.МПЗ.Канбан.РезервироватьВПроизводстве Тогда
					Продолжить;
					КонецЕсли;			
				КонецЕсли; 
			КонецЕсли;
		ТаблицаВремён.Очистить();
		ОблМПЗ.Параметры.МестоХранения = ВыборкаЛинейка.МестоХранения;
		ОблМПЗ.Параметры.МПЗ = ВыборкаМПЗ.МПЗ;
		ЯчейкиКомплектации = ОбщийМодульРаботаСРегистрами.ПолучитьЯчейкуКомплектацииПоМестуХранения(ВыборкаЛинейка.МестоХранения,ВыборкаМПЗ.МПЗ);
		ОблМПЗ.Параметры.КоличествоВЯчейке = ЯчейкиКомплектации.КоличествоВЯчейке;
		ВремяДоПринятияМин = 99999;
		ВремяДоПринятияМакс = 0;
		ВремяИзготовленияМин = 99999;
		ВремяИзготовленияМакс = 0;
		ВремяОборотаМин = 99999;
		ВремяОборотаМакс = 0;
		ВремяПростояМин = 99999;
		ВремяПростояМакс = 0;
		КоличествоОборотов = 0;
		ВыборкаДетальныеЗаписи = ВыборкаМПЗ.Выбрать();
			Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаПринятия) Тогда
				ВремяДоПринятия = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.Период,ВыборкаДетальныеЗаписи.ДатаПринятия,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
				Иначе
 				ВремяДоПринятия = 0;
				КонецЕсли;	
					Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания)и ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаПринятия) Тогда
					ВремяИзготовления = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.ДатаПринятия,ВыборкаДетальныеЗаписи.ДатаОкончания,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
					Иначе	
					ВремяИзготовления = 0;
					КонецЕсли;
						Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) Тогда
						ВремяОборота = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.Период,ВыборкаДетальныеЗаписи.ДатаОкончания,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
						Иначе	
						ВремяОборота = 0;
						КонецЕсли;
				Если ПоКанбанам = 1 Тогда
				ЗапросПростой.Текст = 
					"ВЫБРАТЬ
					|	ЛьготнаяОчередь.Период,
					|	ЛьготнаяОчередь.ДатаОкончания
					|ИЗ
					|	РегистрСведений.ЛьготнаяОчередь КАК ЛьготнаяОчередь
					|ГДЕ
					|	ЛьготнаяОчередь.Период МЕЖДУ &ДатаНач И &ДатаКон
					|	И ЛьготнаяОчередь.Линейка.МестоХраненияКанбанов = &МестоХранения
					|	И ЛьготнаяОчередь.НормаРасходов.Элемент = &МПЗ";	
				ЗапросПростой.УстановитьПараметр("ДатаНач", ВыборкаДетальныеЗаписи.Период);
					Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) Тогда
					ЗапросПростой.УстановитьПараметр("ДатаКон", ВыборкаДетальныеЗаписи.ДатаОкончания);
					Иначе	
					ЗапросПростой.УстановитьПараметр("ДатаКон", ТекущаяДата());
					КонецЕсли;
				ЗапросПростой.УстановитьПараметр("МестоХранения", ВыборкаДетальныеЗаписи.МестоХранения);
				ЗапросПростой.УстановитьПараметр("МПЗ", ВыборкаДетальныеЗаписи.МПЗ);
				РезультатЗапросаПростой = ЗапросПростой.Выполнить();
				ВыборкаПростой = РезультатЗапросаПростой.Выбрать();
					Если ВыборкаПростой.Количество() > 0 Тогда
					ДатаНачЛО = ТекущаяДата();
					ДатаКонЛО = Дата(1,1,1);
						Пока ВыборкаПростой.Следующий() Цикл
						ДатаНачЛО = Мин(ДатаНачЛО,ВыборкаПростой.Период);
							Если ЗначениеЗаполнено(ВыборкаПростой.ДатаОкончания) Тогда
							ДатаКонЛО = Макс(ДатаКонЛО,ВыборкаПростой.ДатаОкончания);
							Иначе
							ДатаКонЛО = Макс(ДатаКонЛО,ТекущаяДата());
							КонецЕсли;	
						КонецЦикла;					
					ВремяПростоя = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ДатаНачЛО,ДатаКонЛО,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);					
					Иначе	
					ВремяПростоя = 0;
					КонецЕсли;
				Иначе	
				ЗапросПростой.Текст = 
					"ВЫБРАТЬ
					|	ПростойЛинейки.Период,
					|	ПростойЛинейки.Окончание
					|ИЗ
					|	РегистрСведений.ПростойЛинейки КАК ПростойЛинейки
					|ГДЕ
					|	ПростойЛинейки.Период МЕЖДУ &ДатаНач И &ДатаКон
					|	И ПростойЛинейки.Линейка.МестоХраненияКанбанов = &МестоХранения
					|	И ПростойЛинейки.Причина = &Причина";
				ЗапросПростой.УстановитьПараметр("ДатаНач", ВыборкаДетальныеЗаписи.Период);
				ЗапросПростой.УстановитьПараметр("ДатаКон", ВыборкаДетальныеЗаписи.Период+10); // прибавим 10 секунд для верности
				ЗапросПростой.УстановитьПараметр("МестоХранения", ВыборкаДетальныеЗаписи.МестоХранения);
				ЗапросПростой.УстановитьПараметр("Причина", ВыборкаДетальныеЗаписи.МПЗ);
				РезультатЗапросаПростой = ЗапросПростой.Выполнить();
				ВыборкаПростой = РезультатЗапросаПростой.Выбрать();
					Если ВыборкаПростой.Следующий() Тогда
					ВремяПростоя = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаПростой.Период,ВыборкаПростой.Окончание,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
					Иначе
					ВремяПростоя = 0;
					КонецЕсли;		
				КонецЕсли;
			ВремяДоПринятияМин = Мин(ВремяДоПринятияМин,ВремяДоПринятия);
			ВремяДоПринятияМакс = Макс(ВремяДоПринятияМакс,ВремяДоПринятия);
			ВремяИзготовленияМин = Мин(ВремяИзготовленияМин,ВремяИзготовления);
			ВремяИзготовленияМакс = Макс(ВремяИзготовленияМакс,ВремяИзготовления);
			ВремяОборотаМин = Мин(ВремяОборотаМин,ВремяОборота);
			ВремяОборотаМакс = Макс(ВремяОборотаМакс,ВремяОборота);
			ВремяПростояМин = Мин(ВремяПростояМин,ВремяПростоя);
			ВремяПростояМакс = Макс(ВремяПростояМакс,ВремяПростоя);
			КоличествоОборотов = КоличествоОборотов + 1;
			КоличествоОборотовИтого = КоличествоОборотовИтого + 1;
			ТЧ = ТаблицаВремён.Добавить();
			ТЧ.ВремяДоПринятия = ВремяДоПринятия;
			ТЧ.ВремяИзготовления = ВремяИзготовления;
			ТЧ.ВремяОборота = ВремяОборота;
			ТЧ.ВремяПростоя = ВремяПростоя;
			КонецЦикла; 
		ОблМПЗ.Параметры.ВремяДоПринятияМин = ВремяДоПринятияМин;
		ОблМПЗ.Параметры.ВремяДоПринятияМакс = ВремяДоПринятияМакс;
		ОблМПЗ.Параметры.ВремяДоПринятияСредн = Окр(ТаблицаВремён.Итог("ВремяДоПринятия")/ТаблицаВремён.Количество(),2,1);
		ОблМПЗ.Параметры.ВремяИзготовленияМин = ВремяИзготовленияМин;
		ОблМПЗ.Параметры.ВремяИзготовленияМакс = ВремяИзготовленияМакс;
		ОблМПЗ.Параметры.ВремяИзготовленияСредн = Окр(ТаблицаВремён.Итог("ВремяИзготовления")/ТаблицаВремён.Количество(),2,1);
		ОблМПЗ.Параметры.ВремяОборотаМин = ВремяОборотаМин;
		ОблМПЗ.Параметры.ВремяОборотаМакс = ВремяОборотаМакс;
		ОблМПЗ.Параметры.ВремяОборотаСредн = Окр(ТаблицаВремён.Итог("ВремяОборота")/ТаблицаВремён.Количество(),2,1);
		ОблМПЗ.Параметры.ВремяПростояМин = ВремяПростояМин;
		ОблМПЗ.Параметры.ВремяПростояМакс = ВремяПростояМакс;
		КоличествоВремёнПростоя = 0;
			Для каждого ТЧ Из ТаблицаВремён Цикл
				Если ТЧ.ВремяПростоя > 0 Тогда	
				КоличествоВремёнПростоя = КоличествоВремёнПростоя + 1;
				КонецЕсли;			
			КонецЦикла; 
		ОблМПЗ.Параметры.ВремяПростояСредн = ?(КоличествоВремёнПростоя > 0,Окр(ТаблицаВремён.Итог("ВремяПростоя")/КоличествоВремёнПростоя,2,1),0);
		ОблМПЗ.Параметры.КоличествоОборотов = КоличествоОборотов;		
	    ТабДок.Вывести(ОблМПЗ);
		КонецЦикла;
	КонецЦикла;
ОблКонец.Параметры.КоличествоОборотовИтого = КоличествоОборотовИтого;
ТабДок.Вывести(ОблКонец); 
ТабДок.ФиксацияСверху = 4;
КонецПроцедуры

&НаСервере
Процедура СформироватьПоИзделиямНаСервере()
ТабДок.Очистить();

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("ПоИзделиям"); 
ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблМПЗ = Макет.ПолучитьОбласть("МПЗ");	
ОблКонец = Макет.ПолучитьОбласть("Конец");	

ОблШапка.Параметры.ДатаНач = Отчет.Период.ДатаНачала;
ОблШапка.Параметры.ДатаКон = Отчет.Период.ДатаОкончания;
ОблШапка.Параметры.Подразделение = Отчет.Подразделение;
	Если ПоКанбанам = 1 Тогда
	ОблШапка.Параметры.ВидПростоя = "Время нахождения в ЛО";
	Иначе
	ОблШапка.Параметры.ВидПростоя = "Время простоя линейки";
	КонецЕсли;
ТабДок.Вывести(ОблШапка);

Запрос = Новый Запрос;
ЗапросПростой = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ОборотКанбанов.МестоХранения КАК МестоХранения,
	|	ОборотКанбанов.МПЗ КАК МПЗ,
	|	ОборотКанбанов.Период,
	|	ОборотКанбанов.ДатаПринятия,
	|	ОборотКанбанов.ДатаПередачи,
	|	ОборотКанбанов.ДатаОкончания,
	|	ОборотКанбанов.МПЗ.Наименование КАК Наименование
	|ИЗ
	|	РегистрСведений.ОборотКанбанов КАК ОборотКанбанов
	|ГДЕ
	|	ОборотКанбанов.Период МЕЖДУ &ДатаНач И &ДатаКон
	|	И ОборотКанбанов.Подразделение = &Подразделение";
Запрос.УстановитьПараметр("ДатаНач", Отчет.Период.ДатаНачала);
Запрос.УстановитьПараметр("ДатаКон", Отчет.Период.ДатаОкончания);
Запрос.УстановитьПараметр("Подразделение", Отчет.Подразделение);
	Если СписокМестХранения.Количество() > 0 Тогда
	Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.МестоХранения В(&СписокМестХранения)";
	Запрос.УстановитьПараметр("СписокМестХранения", СписокМестХранения);
	КонецЕсли;
		Если Канбан <> Неопределено Тогда	
		Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.МПЗ = &МПЗ";
		Запрос.УстановитьПараметр("МПЗ", Канбан);		
		КонецЕсли;
			Если Показывать = 1 Тогда	
			Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.ДатаОкончания <> ДАТАВРЕМЯ(1,1,1,0,0,0)"; 
			ИначеЕсли Показывать = 2 Тогда	
			Запрос.Текст = Запрос.Текст + " И ОборотКанбанов.ДатаОкончания = ДАТАВРЕМЯ(1,1,1,0,0,0)"; 
			КонецЕсли;
Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО Наименование
								|ИТОГИ ПО МПЗ";  
РезультатЗапроса = Запрос.Выполнить();
КоличествоОборотовИтого = 0;
ВыборкаМПЗ = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаМПЗ.Следующий() Цикл
		Если ПоКанбанам = 1 Тогда
			Если ТипЗнч(ВыборкаМПЗ.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если Не ВыборкаМПЗ.МПЗ.Канбан.РезервироватьВПроизводстве Тогда
				Продолжить;
				КонецЕсли;			
			КонецЕсли; 
		Иначе
			Если ТипЗнч(ВыборкаМПЗ.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если ВыборкаМПЗ.МПЗ.Канбан.РезервироватьВПроизводстве Тогда
				Продолжить;
				КонецЕсли;			
			КонецЕсли; 
		КонецЕсли;
	ТаблицаВремён.Очистить();
	ОблМПЗ.Параметры.МПЗ = ВыборкаМПЗ.МПЗ;
	ВремяДоПринятияМин = 99999;
	ВремяДоПринятияМакс = 0;
	ВремяИзготовленияМин = 99999;
	ВремяИзготовленияМакс = 0;
	ВремяОборотаМин = 99999;
	ВремяОборотаМакс = 0;
	ВремяПростояМин = 99999;
	ВремяПростояМакс = 0;
	КоличествоОборотов = 0;
	ВыборкаДетальныеЗаписи = ВыборкаМПЗ.Выбрать();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
			Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаПринятия) Тогда
			ВремяДоПринятия = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.Период,ВыборкаДетальныеЗаписи.ДатаПринятия,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
			Иначе
 			ВремяДоПринятия = 0;
			КонецЕсли;	
				Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания)и ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаПринятия) Тогда
				ВремяИзготовления = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.ДатаПринятия,ВыборкаДетальныеЗаписи.ДатаОкончания,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
				Иначе	
				ВремяИзготовления = 0;
				КонецЕсли;
					Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) Тогда
					ВремяОборота = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаДетальныеЗаписи.Период,ВыборкаДетальныеЗаписи.ДатаОкончания,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
					Иначе	
					ВремяОборота = 0;
					КонецЕсли;
			Если ПоКанбанам = 1 Тогда
			ЗапросПростой.Текст = 
				"ВЫБРАТЬ
				|	ЛьготнаяОчередь.Период,
				|	ЛьготнаяОчередь.ДатаОкончания
				|ИЗ
				|	РегистрСведений.ЛьготнаяОчередь КАК ЛьготнаяОчередь
				|ГДЕ
				|	ЛьготнаяОчередь.Период МЕЖДУ &ДатаНач И &ДатаКон
				|	И ЛьготнаяОчередь.Линейка.МестоХраненияКанбанов = &МестоХранения
				|	И ЛьготнаяОчередь.НормаРасходов.Элемент = &МПЗ";	
			ЗапросПростой.УстановитьПараметр("ДатаНач", ВыборкаДетальныеЗаписи.Период);
				Если ЗначениеЗаполнено(ВыборкаДетальныеЗаписи.ДатаОкончания) Тогда
				ЗапросПростой.УстановитьПараметр("ДатаКон", ВыборкаДетальныеЗаписи.ДатаОкончания);
				Иначе	
				ЗапросПростой.УстановитьПараметр("ДатаКон", ТекущаяДата());
				КонецЕсли;
			ЗапросПростой.УстановитьПараметр("МестоХранения", ВыборкаДетальныеЗаписи.МестоХранения);
			ЗапросПростой.УстановитьПараметр("МПЗ", ВыборкаДетальныеЗаписи.МПЗ);
			РезультатЗапросаПростой = ЗапросПростой.Выполнить();
			ВыборкаПростой = РезультатЗапросаПростой.Выбрать();
				Если ВыборкаПростой.Количество() > 0 Тогда
				ДатаНачЛО = ТекущаяДата();
				ДатаКонЛО = Дата(1,1,1);
					Пока ВыборкаПростой.Следующий() Цикл
					ДатаНачЛО = Мин(ДатаНачЛО,ВыборкаПростой.Период);
						Если ЗначениеЗаполнено(ВыборкаПростой.ДатаОкончания) Тогда
						ДатаКонЛО = Макс(ДатаКонЛО,ВыборкаПростой.ДатаОкончания);
						Иначе
						ДатаКонЛО = Макс(ДатаКонЛО,ТекущаяДата());
						КонецЕсли;	
					КонецЦикла;					
				ВремяПростоя = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ДатаНачЛО,ДатаКонЛО,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);					
				Иначе	
				ВремяПростоя = 0;
				КонецЕсли;
			Иначе	
			ЗапросПростой.Текст = 
				"ВЫБРАТЬ
				|	ПростойЛинейки.Период,
				|	ПростойЛинейки.Окончание
				|ИЗ
				|	РегистрСведений.ПростойЛинейки КАК ПростойЛинейки
				|ГДЕ
				|	ПростойЛинейки.Период МЕЖДУ &ДатаНач И &ДатаКон
				|	И ПростойЛинейки.Линейка.МестоХраненияКанбанов = &МестоХранения
				|	И ПростойЛинейки.Причина = &Причина";
			ЗапросПростой.УстановитьПараметр("ДатаНач", ВыборкаДетальныеЗаписи.Период);
			ЗапросПростой.УстановитьПараметр("ДатаКон", ВыборкаДетальныеЗаписи.Период+10); // прибавим 10 секунд для верности
			ЗапросПростой.УстановитьПараметр("МестоХранения", ВыборкаДетальныеЗаписи.МестоХранения);
			ЗапросПростой.УстановитьПараметр("Причина", ВыборкаДетальныеЗаписи.МПЗ);
			РезультатЗапросаПростой = ЗапросПростой.Выполнить();
			ВыборкаПростой = РезультатЗапросаПростой.Выбрать();
				Если ВыборкаПростой.Следующий() Тогда
				ВремяПростоя = ОбщийМодульВызовСервера.ПолучитьВремяМеждуДатами(ВыборкаПростой.Период,ВыборкаПростой.Окончание,Размерность,Отчет.ВычестьНерабочееВремя,Отчет.КолНерабочихЧасов,Отчет.БезВыходных);
				Иначе
				ВремяПростоя = 0;
				КонецЕсли;		
			КонецЕсли;
			ВремяДоПринятияМин = Мин(ВремяДоПринятияМин,ВремяДоПринятия);
			ВремяДоПринятияМакс = Макс(ВремяДоПринятияМакс,ВремяДоПринятия);
			ВремяИзготовленияМин = Мин(ВремяИзготовленияМин,ВремяИзготовления);
			ВремяИзготовленияМакс = Макс(ВремяИзготовленияМакс,ВремяИзготовления);
			ВремяОборотаМин = Мин(ВремяОборотаМин,ВремяОборота);
			ВремяОборотаМакс = Макс(ВремяОборотаМакс,ВремяОборота);
			ВремяПростояМин = Мин(ВремяПростояМин,ВремяПростоя);
			ВремяПростояМакс = Макс(ВремяПростояМакс,ВремяПростоя);
			КоличествоОборотов = КоличествоОборотов + 1;
			КоличествоОборотовИтого = КоличествоОборотовИтого + 1;
			ТЧ = ТаблицаВремён.Добавить();
			ТЧ.ВремяДоПринятия = ВремяДоПринятия;
			ТЧ.ВремяИзготовления = ВремяИзготовления;
			ТЧ.ВремяОборота = ВремяОборота;
			ТЧ.ВремяПростоя = ВремяПростоя;
			КонецЦикла; 
	ОблМПЗ.Параметры.ВремяДоПринятияМин = ВремяДоПринятияМин;
	ОблМПЗ.Параметры.ВремяДоПринятияМакс = ВремяДоПринятияМакс;
	ОблМПЗ.Параметры.ВремяДоПринятияСредн = Окр(ТаблицаВремён.Итог("ВремяДоПринятия")/ТаблицаВремён.Количество(),2,1);
	ОблМПЗ.Параметры.ВремяИзготовленияМин = ВремяИзготовленияМин;
	ОблМПЗ.Параметры.ВремяИзготовленияМакс = ВремяИзготовленияМакс;
	ОблМПЗ.Параметры.ВремяИзготовленияСредн = Окр(ТаблицаВремён.Итог("ВремяИзготовления")/ТаблицаВремён.Количество(),2,1);
	ОблМПЗ.Параметры.ВремяОборотаМин = ВремяОборотаМин;
	ОблМПЗ.Параметры.ВремяОборотаМакс = ВремяОборотаМакс;
	ОблМПЗ.Параметры.ВремяОборотаСредн = Окр(ТаблицаВремён.Итог("ВремяОборота")/ТаблицаВремён.Количество(),2,1);
	ОблМПЗ.Параметры.ВремяПростояМин = ВремяПростояМин;
	ОблМПЗ.Параметры.ВремяПростояМакс = ВремяПростояМакс;
	КоличествоВремёнПростоя = 0;
		Для каждого ТЧ Из ТаблицаВремён Цикл
			Если ТЧ.ВремяПростоя > 0 Тогда	
			КоличествоВремёнПростоя = КоличествоВремёнПростоя + 1;
			КонецЕсли;			
		КонецЦикла; 
	ОблМПЗ.Параметры.ВремяПростояСредн = ?(КоличествоВремёнПростоя > 0,Окр(ТаблицаВремён.Итог("ВремяПростоя")/КоличествоВремёнПростоя,2,1),0);
	ОблМПЗ.Параметры.КоличествоОборотов = КоличествоОборотов;		
    ТабДок.Вывести(ОблМПЗ);
	КонецЦикла;
ОблКонец.Параметры.КоличествоОборотовИтого = КоличествоОборотовИтого;
ТабДок.Вывести(ОблКонец); 
ТабДок.ФиксацияСверху = 4;
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)	
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
		Если ВидОтчёта = 1 Тогда
		СформироватьНаСервере(Канбан);			
		ИначеЕсли ВидОтчёта = 2 Тогда	
		СформироватьПоМестамХраненияНаСервере();
		Иначе
		СформироватьПоИзделиямНаСервере();
		КонецЕсли;
	КонецЕсли;  
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
ПоДатам = 1;
ВидОтчёта = 1;
СортироватьПо = 1;
ПоКанбанам = 1;
Размерность = 1;
Показывать = 0;
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	Если ВидОтчёта = 1 Тогда	
		Если Показывать = 1 Тогда
		Элементы.ПоДатам.Доступность = Истина;
		Возврат;
		КонецЕсли;
	КонецЕсли; 
ПоДатам = 1;
Элементы.ПоДатам.Доступность = Ложь;
КонецПроцедуры

&НаКлиенте
Процедура ТабДокОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	Если ВидОтчёта > 1 Тогда
		Если ТипЗнч(Расшифровка) =  Тип("СправочникСсылка.Номенклатура") Тогда
		СтандартнаяОбработка = Ложь;
		ТД = Новый ТабличныйДокумент;

		СформироватьНаСервере(Расшифровка,ТД);
		ТД.Показать("Отчёт по обороту канбана "+Расшифровка);	
		КонецЕсли;
	КонецЕсли;  	
КонецПроцедуры

&НаКлиенте
Процедура ВидОтчётаПриИзменении(Элемент)
ПриОткрытии(Ложь);
КонецПроцедуры

&НаКлиенте
Процедура ПоказыватьПриИзменении(Элемент)
ПриОткрытии(Ложь);
КонецПроцедуры
