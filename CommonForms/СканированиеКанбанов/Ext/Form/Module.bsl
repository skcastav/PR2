﻿
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Для каждого Изделие Из ЭтаФорма.Параметры.СписокКанбанов Цикл	
	ТЧ = ТаблицаКанбанов.Добавить();
	ТЧ.Изделие = Изделие.Значение;
	КонецЦикла; 
КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
ОписаниеОшибки = "";
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
   Если Не МенеджерОборудованияКлиент.ПодключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО, ОписаниеОшибки) Тогда
      ТекстСообщения = НСтр("ru = 'При подключении оборудования произошла ошибка:""%ОписаниеОшибки%"".'");
      ТекстСообщения = СтрЗаменить(ТекстСообщения, "%ОписаниеОшибки%" , ОписаниеОшибки);
      Сообщить(ТекстСообщения);
   КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры

&НаСервере
Процедура КнопкаОКНаСервере()
ПЗ = Параметры.ПроизводственноеЗадание.ПолучитьОбъект();
	Для каждого ТЧ Из ТаблицаКанбанов Цикл
	ТЧ_К = ПЗ.Канбаны.Добавить();
	ТЧ_К.Изделие = ТЧ.Изделие;
	ТЧ_К.МТК = ТЧ.МТК;		
	КонецЦикла;
ПЗ.Записать();
КонецПроцедуры

&НаСервере
Функция ПроверитьСканирование()
	Для каждого ТЧ Из ТаблицаКанбанов Цикл
		Если ТЧ.МТК.Пустая() Тогда
		Возврат(Ложь);
		КонецЕсли; 
	КонецЦикла; 
Возврат(Истина);	
КонецФункции

&НаКлиенте
Процедура КнопкаОК(Команда)
	Если ПроверитьСканирование() Тогда	
	КнопкаОКНаСервере();
	ЭтаФорма.Закрыть(Истина);
	Иначе
	Сообщить("Отсканированы не все канбаны!");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура КнопкаОтмена(Команда)
ЭтаФорма.Закрыть(Неопределено);
КонецПроцедуры

&НаСервере
Процедура ДобавитьПоQRКодуНаСервере(Данные)
Массив = ОбщийМодульВызовСервера.РазложитьСтрокуВМассив(Данные,";");
	Если Массив[0] = "4" Тогда
	ПЗ = ЗначениеИзСтрокиВнутр(Массив[1]);	
	Выборка = ТаблицаКанбанов.НайтиСтроки(Новый Структура("Изделие",ПЗ.Изделие));
		Если Выборка.Количество() > 0 Тогда	
		Выборка[0].МТК = ПЗ.ДокументОснование;
		КонецЕсли; 
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	Если ЭтаФорма.ВводДоступен() Тогда
	ДобавитьПоQRКодуНаСервере(Данные);
	КонецЕсли;
КонецПроцедуры
