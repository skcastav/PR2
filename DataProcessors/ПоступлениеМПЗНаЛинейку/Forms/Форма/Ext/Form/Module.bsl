﻿
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
Процедура ПриЗакрытии(ЗавершениеРаботы)
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры 
            
&НаСервере
Функция ПолучитьМестоХраненияКанбанов(Линейка)
Возврат(Линейка.МестоХраненияКанбанов);
КонецФункции
           
&НаСервере
Функция НайтиПередачуНаЛинейку(МестоХраненияКанбанов,МПЗ,НомерЯчейки)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ПередачиНаЛинейкиОстатки.ПередачаНаЛинейку
	|ИЗ
	|	РегистрНакопления.ПередачиНаЛинейки.Остатки(&НаДату, ) КАК ПередачиНаЛинейкиОстатки
	|ГДЕ
	|	ПередачиНаЛинейкиОстатки.МестоХранения = &МестоХраненияКанбанов
	|	И ПередачиНаЛинейкиОстатки.МПЗ = &МПЗ
	|	И ПередачиНаЛинейкиОстатки.НомерЯчейки = &НомерЯчейки";
Запрос.УстановитьПараметр("НаДату", ТекущаяДата());
Запрос.УстановитьПараметр("МестоХраненияКанбанов", МестоХраненияКанбанов);
Запрос.УстановитьПараметр("МПЗ", МПЗ);
Запрос.УстановитьПараметр("НомерЯчейки", НомерЯчейки);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	Возврат(ВыборкаДетальныеЗаписи.ПередачаНаЛинейку);	
	КонецЦикла;
Возврат(Документы.ПередачаНаЛинейку.ПустаяСсылка());	
КонецФункции 

&НаСервере
Функция ПолучитьКоличествоИзПередачиНаЛинейку(ПНЛ)
Возврат(ПНЛ.Количество);	
КонецФункции

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
	Если ЭтаФорма.ВводДоступен() Тогда                                  
	Массив = ОбщийМодульВызовСервера.РазложитьСтрокуВМассив(Данные,";");
		Если Массив[0] = "3" Тогда
		ЗначениеПараметра1 = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[1]);
			Если ЗначениеПараметра1 = Неопределено Тогда
			Сообщить("Линейка или место хранения не найдена!");
			Возврат;	
			КонецЕсли;
		Канбан = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[3]);
			Если Канбан = Неопределено Тогда
			Сообщить(Массив[3]+" - канбан не найден!");
			Возврат;	
			КонецЕсли;
		МестоХраненияОтправитель = ОбщийМодульВызовСервера.ПолучитьМестоХраненияПоКоду(Массив[2]);
			Если ТипЗнч(ЗначениеПараметра1) = Тип("СправочникСсылка.Линейки") Тогда
			МестоХраненияКанбанов = ПолучитьМестоХраненияКанбанов(ЗначениеПараметра1);
			Иначе
			МестоХраненияКанбанов = ЗначениеПараметра1;			
			КонецЕсли;
        НомерЯчейки = Число(Массив[5]);
		ИначеЕсли Массив[0] = "4" Тогда
		ПЗ = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[1]);
		МТК = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(ПЗ,"ДокументОснование");
		Линейка = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(МТК,"Линейка");		
		МестоХраненияОтправитель = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(Линейка,"МестоХраненияГП");
		МестоХраненияКанбанов = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(МТК,"МестоХраненияПотребитель");
		Канбан = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(МТК,"Номенклатура");
		НомерЯчейки = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(МТК,"НомерЯчейки");		
		ИначеЕсли Массив[0] = "7" Тогда
		Линейка = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[1]);
		МестоХраненияОтправитель = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(Линейка,"МестоХраненияГП");
		МестоХраненияКанбанов = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[2]);
        Канбан = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Массив[3]);
        НомерЯчейки = Число(Массив[5]);
		Иначе    
		ЗначениеПараметра = ОбщийМодульВызовСервера.ПолучитьЗначениеИзСтрокиВнутр(Данные);
			Если ТипЗнч(ЗначениеПараметра) = Тип("СправочникСсылка.Сотрудники") Тогда
			Сотрудник = ЗначениеПараметра;
			Возврат;	
			ИначеЕсли ТипЗнч(ЗначениеПараметра) = Тип("ДокументСсылка.МаршрутнаяКарта") Тогда
			Канбан = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(ЗначениеПараметра,"Номенклатура");
			Линейка = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(ЗначениеПараметра,"Линейка");
			МестоХраненияОтправитель = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(Линейка,"МестоХраненияГП");
			МестоХраненияКанбанов = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(ЗначениеПараметра,"МестоХраненияПотребитель");
			НомерЯчейки = ОбщийМодульВызовСервера.ПолучитьЗначениеРеквизита(ЗначениеПараметра,"НомерЯчейки");		
			Иначе	
			Сообщить("Неверный формат кода!");
			Возврат;
			КонецЕсли;			
		КонецЕсли;    
	Выборка = ТаблицаКанбанов.НайтиСтроки(Новый Структура("Канбан,МестоХранения,МестоХраненияКанбанов,НомерЯчейки",Канбан,МестоХраненияОтправитель,МестоХраненияКанбанов,НомерЯчейки));
		Если Выборка.Количество() = 0 Тогда
		ТЧ = ТаблицаКанбанов.Добавить();
		ТЧ.НомерСтроки = ТаблицаКанбанов.Количество();         
		ТЧ.Канбан = Канбан;
		ТЧ.МестоХранения = МестоХраненияОтправитель;
		ТЧ.МестоХраненияКанбанов = МестоХраненияКанбанов;   
		ТЧ.НомерЯчейки = НомерЯчейки;
		ТЧ.ПередачаНаЛинейку = НайтиПередачуНаЛинейку(МестоХраненияКанбанов,Канбан,НомерЯчейки);
			Если Не ТЧ.ПередачаНаЛинейку.Пустая() Тогда
			ТЧ.Количество = ПолучитьКоличествоИзПередачиНаЛинейку(ТЧ.ПередачаНаЛинейку);
			КонецЕсли;
		Иначе
        Сообщить("Канбан уже отсканирован в таблицу!");
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры
                
&НаСервере
Функция СоздатьПоступление(ТЧ,ДатаПоступления)
	Если ТЧ.ПередачаНаЛинейку.Пустая() Тогда
	Возврат("Передача не создана!");
	КонецЕсли;
		Попытка
		НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
		Поступление = Документы.ПоступлениеНаЛинейку.СоздатьДокумент();
		Поступление.ДокументОснование = ТЧ.ПередачаНаЛинейку;
		Поступление.Дата = ДатаПоступления;
		Поступление.Автор = Сотрудник;
		Поступление.Подразделение = ТЧ.МестоХраненияКанбанов.Подразделение;
		Поступление.УстановитьНовыйНомер(ПрисвоитьПрефикс(ТЧ.МестоХраненияКанбанов.Подразделение));
		Поступление.НомерЯчейки = ТЧ.НомерЯчейки;
		Поступление.МестоХранения = ТЧ.МестоХраненияКанбанов;
		Поступление.МПЗ = ТЧ.Канбан;
		Поступление.Количество = ТЧ.Количество;
	    Поступление.Записать(РежимЗаписиДокумента.Проведение);
			Если ТипЗнч(ТЧ.Канбан) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если Не ТЧ.Канбан.Канбан.Пустая() Тогда
					Если ТЧ.Канбан.Канбан.Подразделение.ОформлятьПустыеКанбаны > 0 Тогда
						Если Не ОбщийМодульРаботаСРегистрами.ОформитьПоступлениеКанбанаПоМестуХранения(ТЧ.МестоХранения,ТЧ.МестоХраненияКанбанов,ТЧ.Канбан,ТЧ.НомерЯчейки,Поступление.Автор,ДатаПоступления) Тогда
						ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
						Возврат("Поступление не оформлено!");				
						КонецЕсли; 
					КонецЕсли; 	
				КонецЕсли;
			Иначе
				Если Константы.МестоХраненияОсновное.Получить().Подразделение.ОформлятьПустыеКанбаны > 0 Тогда
					Если Не ОбщийМодульРаботаСРегистрами.ОформитьПоступлениеКанбанаПоМестуХранения(ТЧ.МестоХранения,ТЧ.МестоХраненияКанбанов,ТЧ.Канбан,ТЧ.НомерЯчейки,Поступление.Автор,ДатаПоступления) Тогда
					ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
					Возврат("Поступление не оформлено!");				
					КонецЕсли; 
				КонецЕсли; 
			КонецЕсли;
				Если Не ТЧ.МестоФиксации.Пустая() Тогда
				ОЯК = РегистрыСведений.ОборотЯчеекКанбанов.СоздатьМенеджерЗаписи();
				ОЯК.Период = ТекущаяДата();
				ОЯК.МестоФиксации = ТЧ.МестоФиксации;
				ОЯК.МестоХранения = ТЧ.МестоХраненияКанбанов;
					Если ТипЗнч(ТЧ.Канбан) = Тип("СправочникСсылка.Материалы") Тогда
					ОЯК.Подразделение = Константы.МестоХраненияОсновное.Получить().Подразделение;
					Иначе	
					ОЯК.Подразделение = ТЧ.Канбан.Канбан.Подразделение;
					КонецЕсли; 
				ОЯК.МПЗ = ТЧ.Канбан;
				ОЯК.НомерЯчейки = ТЧ.НомерЯчейки;
				ОЯК.Количество = ТЧ.Количество;
				ОЯК.Записать();
				КонецЕсли;  
		ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
		Возврат(Неопределено);
		Исключение
		ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
		Возврат(ОписаниеОшибки());
		КонецПопытки;
КонецФункции

&НаСервере
Процедура ПринятьКанбаныНаСервере()
СписокУдаления = Новый СписокЗначений;
        
ДатаПоступления = ТекущаяДата();
	Для каждого ТЧ Из ТаблицаКанбанов Цикл 
	Результат = СоздатьПоступление(ТЧ,ДатаПоступления);
		Если Результат = Неопределено Тогда	
		СписокУдаления.Добавить(ТЧ);
		Иначе
		ТЧ.Комментарий = Результат;
		КонецЕсли;
	ДатаПоступления = ДатаПоступления + 1;		
	КонецЦикла;
		Для каждого Стр Из СписокУдаления Цикл
		ТаблицаКанбанов.Удалить(Стр.Значение);
		КонецЦикла; 
Сотрудник = Справочники.Сотрудники.ПустаяСсылка();
КонецПроцедуры

&НаКлиенте
Процедура ПринятьКанбаны(Команда)
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
	ПринятьКанбаныНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОчиститьТаблицу(Команда)
ТаблицаКанбанов.Очистить();
КонецПроцедуры

