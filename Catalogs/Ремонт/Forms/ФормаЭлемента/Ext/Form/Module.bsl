﻿
&НаСервере
Функция СортироватьПоПорядку(ТекЗнач)
Перем ТемпНач,ТемпКон;

	Если (ТекЗнач = "")или(Найти(ТекЗнач,"-") > 0) Тогда
	Возврат(ТекЗнач);		
	КонецЕсли;
		Для к = 1 по 3 Цикл
			Если (КодСимвола(Сред(ТекЗнач,к,1)) > 47)и(КодСимвола(Сред(ТекЗнач,к,1)) < 58) Тогда
			ТемпНач = Лев(ТекЗнач,к-1);
			ТекЗнач = СтрЗаменить(ТекЗнач,ТемпНач,"");
				Если Найти(ТекЗнач,".") > 0 Тогда
				ТемпКон = Сред(ТекЗнач,Найти(ТекЗнач,"."));
				ТекЗнач = СтрЗаменить(ТекЗнач,ТемпКон,"");
				КонецЕсли;	                            
			    	Пока СтрДлина(ТекЗнач) < 5 Цикл
			    	ТекЗнач = "#"+ТекЗнач;	
					КонецЦикла;
			ТекЗнач = ТемпНач+ТекЗнач+ТемпКон;		
			Прервать;		
			КонецЕсли;
		КонецЦикла;
Возврат(СокрЛП(ТекЗнач));	
КонецФункции

&НаСервере
Процедура ПолучитьСписокЭлементовСпецификации(Спецификация,тДерево,СтрЭтап)
ТаблицаМПЗ = Новый ТаблицаЗначений;

ТаблицаМПЗ.Колонки.Добавить("НР",Новый ОписаниеТипов("СправочникСсылка.НормыРасходов"));
ТаблицаМПЗ.Колонки.Добавить("ПозицияСортировка",Новый ОписаниеТипов("Строка",Новый КвалификаторыСтроки(100)));

Основа = Справочники.НормыРасходов.ПустаяСсылка();
НР = Справочники.НормыРасходов.Выбрать(,Спецификация);
	Пока НР.Следующий() Цикл
		Если НР.ПометкаУдаления Тогда
		Продолжить;	
		КонецЕсли;
	Отбор = Новый Структура("НормаРасходов",НР.Ссылка);
	Нормы = РегистрыСведений.НормыРасходов.ПолучитьПоследнее(ПолучитьДатуЗапускаПЗ(),Отбор);
		Если Нормы.Норма = 0 Тогда
		Продолжить;	
		КонецЕсли;	
			Если ТипЗнч(НР.Элемент) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если НР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Основа Тогда
				Основа = НР.Ссылка;
				Иначе
				Стр = СтрЭтап.Строки.Добавить();
				ПЗ = ПолучитьПроизводственноеЗадание();
					Если ПЗ <> Неопределено Тогда
					ВыбАналог = ПЗ.Аналоги.НайтиСтроки(Новый Структура("Спецификация,НормаРасходов",Спецификация,НР.Ссылка));
						Если ВыбАналог.Количество() > 0 Тогда
						АналогНР = ВыбАналог[0].АналогНормыРасходов;
						Стр.НормаРасходов = АналогНР;
						Стр.ВидМПЗ = АналогНР.ВидЭлемента;
						Стр.МПЗ = АналогНР.Элемент;
							Если АналогНР.ВидЭлемента <> Перечисления.ВидыЭлементовНормРасходов.Материал Тогда
							Стр.Канбан = АналогНР.Элемент.Канбан;
							КонецЕсли; 
						Стр.Аналог = Истина;
						Иначе
						Стр.НормаРасходов = НР.Ссылка;
						Стр.ВидМПЗ = НР.ВидЭлемента;
						Стр.МПЗ = НР.Элемент;
						Стр.Канбан = НР.Элемент.Канбан;
						КонецЕсли;
					Стр.Позиция = НР.Позиция;
					Стр.ЭтапСпецификации = Спецификация;
						Если Не НР.Элемент.Канбан.НеРаскрыватьСпецификациюПриРемонте Тогда
						ПолучитьСписокЭлементовСпецификации(НР.Элемент,тДерево,Стр);
						КонецЕсли;					
					Иначе	
					Стр.НормаРасходов = НР.Ссылка;
					Стр.ВидМПЗ = НР.ВидЭлемента;
					Стр.МПЗ = НР.Элемент;
					Стр.Канбан = НР.Элемент.Канбан;	
					Стр.Позиция = НР.Позиция;
					Стр.ЭтапСпецификации = Спецификация;
						Если Не НР.Элемент.Канбан.НеРаскрыватьСпецификациюПриРемонте Тогда
						ПолучитьСписокЭлементовСпецификации(НР.Элемент,тДерево,Стр);
						КонецЕсли;				
					КонецЕсли;  
				КонецЕсли;
			ИначеЕсли ТипЗнч(НР.Элемент) = Тип("СправочникСсылка.Материалы") Тогда
			ТЧ = ТаблицаМПЗ.Добавить();
			ТЧ.НР = НР.Ссылка;
			ТЧ.ПозицияСортировка = СортироватьПоПорядку(СокрЛП(НР.Позиция));
			КонецЕсли;
	КонецЦикла;	
		Если Не Основа.Пустая() Тогда
		Стр = СтрЭтап.Строки.Добавить();
		Стр.НормаРасходов = Основа;
		Стр.ВидМПЗ = Основа.ВидЭлемента;
		Стр.МПЗ = Основа.Элемент;
		Стр.Канбан = Основа.Элемент.Канбан;
		Стр.ЭтапСпецификации = Спецификация;
		ПолучитьСписокЭлементовСпецификации(Основа.Элемент,тДерево,Стр);
		КонецЕсли;
ТаблицаМПЗ.Сортировать("ПозицияСортировка");
	Для каждого ТЧ Из ТаблицаМПЗ Цикл
	Стр = СтрЭтап.Строки.Добавить();
	ПЗ = ПолучитьПроизводственноеЗадание();
		Если ПЗ <> Неопределено Тогда
		ВыбАналог = ПЗ.Аналоги.НайтиСтроки(Новый Структура("Спецификация,НормаРасходов",Спецификация,ТЧ.НР));
			Если ВыбАналог.Количество() > 0 Тогда
			АналогНР = ВыбАналог[0].АналогНормыРасходов;
			Стр.НормаРасходов = АналогНР;
			Стр.ВидМПЗ = АналогНР.ВидЭлемента;
			Стр.МПЗ = АналогНР.Элемент;
			Стр.Аналог = Истина;
			Иначе
			Стр.НормаРасходов = ТЧ.НР;
			Стр.ВидМПЗ = ТЧ.НР.ВидЭлемента;
			Стр.МПЗ = ТЧ.НР.Элемент;
			КонецЕсли;
		Иначе
		Стр.НормаРасходов = ТЧ.НР;
		Стр.ВидМПЗ = ТЧ.НР.ВидЭлемента;
		Стр.МПЗ = ТЧ.НР.Элемент;
		КонецЕсли;
	Стр.Позиция = ТЧ.НР.Позиция;
	Стр.ЭтапСпецификации = Спецификация;
	КонецЦикла; 
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	Если Объект.ВидРемонта = Перечисления.ВидыРемонта.Канбан Тогда
	Элементы.ЭтапВхода.Видимость = Ложь;
	Элементы.БарКод.Видимость = Ложь;
	Элементы.КодDanfoss.Видимость = Ложь;
	Элементы.ВозвратнаяТара.Видимость = Ложь;
	Элементы.ЭлементыРемонтаМТК.Видимость = Ложь;
	Элементы.ПереместитьИзделиеВБрак.Видимость = Истина;
	ИначеЕсли Объект.ВидРемонта = Перечисления.ВидыРемонта.БракКанбан Тогда
	Элементы.ЭтапВхода.Видимость = Ложь;
	Элементы.БарКод.Видимость = Ложь;
	Элементы.КодDanfoss.Видимость = Ложь;
	Элементы.ВозвратнаяТара.Видимость = Ложь;
	Элементы.ЭлементыРемонтаМТК.Видимость = Ложь;
	Элементы.ПереместитьИзделиеВБрак.Видимость = Ложь;
	Иначе
	КодDanfoss = ОбщийМодульВызовСервера.ПолучитьКодDanfoss(Объект.БарКод);
		Если ТипЗнч(Объект.ПроизводственноеЗадание) = Тип("ДокументСсылка.ПроизводственноеЗадание") Тогда
		ВозвратнаяТара = Объект.ПроизводственноеЗадание.ВозвратнаяТара;
		Элементы.СчитатьIMEI.Видимость = Истина;
		КонецЕсли; 
	КонецЕсли;
тДеревоСпецификации = РеквизитФормыВЗначение("ДеревоСпецификации");
СтрСпец = тДеревоСпецификации.Строки.Добавить();
СтрСпец.МПЗ = Объект.ЭтапВхода;
СтрСпец.Канбан = Объект.ЭтапВхода.Канбан;
ПолучитьСписокЭлементовСпецификации(Объект.ЭтапВхода,тДеревоСпецификации,СтрСпец);
ЗначениеВРеквизитФормы(тДеревоСпецификации, "ДеревоСпецификации");
КонецПроцедуры

&НаСервере
Функция СоздатьПеремещениеНаЛинейку()
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;
	Перемещение = Документы.ДвижениеМПЗ.СоздатьДокумент();
	Перемещение.Дата = ТекущаяДата();
	Перемещение.УстановитьНовыйНомер(ПрисвоитьПрефикс(Объект.Линейка.Подразделение));
	Перемещение.Автор = ПараметрыСеанса.Пользователь;
	Перемещение.ДокументОснование = Объект.ПроизводственноеЗадание;
	Перемещение.Подразделение = Объект.Линейка.Подразделение;
	Перемещение.МестоХранения = Объект.Линейка.Подразделение.МестоХраненияРемонта;
		Если Объект.ПроизводственноеЗадание.ДокументОснование.МестоХраненияПотребитель.Пустая() Тогда
		Перемещение.МестоХраненияВ = Объект.Линейка.МестоХраненияГП;
		Иначе
		Перемещение.МестоХраненияВ = Объект.ПроизводственноеЗадание.ДокументОснование.МестоХраненияПотребитель;
		КонецЕсли;
	ТЧ = Перемещение.ТабличнаяЧасть.Добавить();
	ТЧ.ВидМПЗ = Перечисления.ВидыМПЗ.Полуфабрикаты;
	ТЧ.МПЗ = Объект.Изделие;
	ТЧ.Количество = Объект.Количество/Объект.Изделие.ОсновнаяЕдиницаИзмерения.Коэффициент;
	ТЧ.ЕдиницаИзмерения =  Объект.Изделие.ОсновнаяЕдиницаИзмерения;	
	Перемещение.Записать(РежимЗаписиДокумента.Проведение);
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Ложь);
	КонецПопытки;
Возврат(Истина);	
КонецФункции

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)
	Если Объект.ВидРемонта <> Перечисления.ВидыРемонта.БракКанбан Тогда
		Если Объект.Статус = Перечисления.СтатусыРемонта.Окончен Тогда	
			Попытка
			НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;	
				Если СокрЛП(Объект.РабочееМесто.ГруппаРабочихМест.Префикс) = "БФ" Тогда
				РабочиеМеста = Справочники.РабочиеМестаЛинеек.Выбрать(,,Новый Структура("Линейка",Объект.Линейка));
				ВыбРабочееМесто = Неопределено;
					Пока РабочиеМеста.Следующий() Цикл
						Если РабочиеМеста.ЭтоГруппа Тогда
						Продолжить;		
						КонецЕсли;
							Если СокрЛП(РабочиеМеста.ГруппаРабочихМест.Префикс) = "СТ" Тогда	
								Если РабочиеМеста.Стенд.СБуфером Тогда
								ВыбРабочееМесто = РабочиеМеста.Ссылка;
								Прервать;						
								КонецЕсли; 
							КонецЕсли; 
					КонецЦикла;
						Если ВыбРабочееМесто = Неопределено Тогда
						Сообщить("Рабочее место <Стенд с буфером> не найдено в выбранной линейке!");
						ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
						Возврат;
						КонецЕсли; 
				Иначе
				ВыбРабочееМесто = Объект.РабочееМесто;
				КонецЕсли; 		
			НаборЗаписей = РегистрыСведений.ЭтапыПроизводственныхЗаданий.СоздатьНаборЗаписей();
			НаборЗаписей.Отбор.ПЗ.Установить(Объект.ПроизводственноеЗадание);
			НаборЗаписей.Прочитать();
			    Для Каждого Запись Из НаборЗаписей Цикл 
			    	Если Запись.РабочееМесто = ВыбРабочееМесто Тогда
					Запись.Ремонт = Ложь;
					Прервать;
					КонецЕсли;  
			    КонецЦикла;
			НаборЗаписей.Записать();
				Если СокрЛП(ВыбРабочееМесто.ГруппаРабочихМест.Префикс) = "СТ" Тогда
				СуществующийСП = РегистрыСведений.СтендовыйПрогон.ПолучитьПоследнее(,Новый Структура("ПЗ",Объект.ПроизводственноеЗадание));
				СП = РегистрыСведений.СтендовыйПрогон.СоздатьМенеджерЗаписи();
				СП.Период = ТекущаяДата();
				СП.ПЗ = Объект.ПроизводственноеЗадание;
				СП.Изделие = Объект.Изделие;
				СП.БарКод = Объект.БарКод;
				СП.Стенд = ВыбРабочееМесто.Стенд;
				СП.Прогон = СуществующийСП.Прогон+1;
				СП.ИсполнительПоступление = ВыбРабочееМесто.Стенд.Исполнитель;
				СП.ДатаПоступления = ТекущаяДата();
				СП.ИсполнительПостановка = ВыбРабочееМесто.Стенд.Исполнитель;
				СП.ДатаПостановки = ТекущаяДата();
				СП.Записать();		
				КонецЕсли; 
					Если Объект.ВидРемонта = Перечисления.ВидыРемонта.Канбан Тогда
						Если Не Объект.Линейка.Подразделение.МестоХраненияРемонта.Пустая() Тогда
							Если Не СоздатьПеремещениеНаЛинейку() Тогда
							ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
							КонецЕсли; 
						КонецЕсли; 
					КонецЕсли;
			ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
			Исключение
			Сообщить(ОписаниеОшибки());
			ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
			КонецПопытки;
		КонецЕсли;
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ПолучитьСтатусНаСервере()
Возврат(Перечисления.СтатусыРемонта.Индекс(Объект.Статус));
КонецФункции

&НаСервере
Процедура ДобавитьЭлементРемонтаНаСервере(НР)
	Если НР = Неопределено Тогда
	Сообщить("Запрещено выбирать само изделие ремонта!");
	Возврат;	
	ИначеЕсли НР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Набор Тогда	
	Сообщить("Запрещено выбирать набор в качестве элемента ремонта!");
	Возврат;
	ИначеЕсли НР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Основа Тогда
		Если Объект.ВидРемонта = Перечисления.ВидыРемонта.Канбан Тогда
		Сообщить("Запрещено выбирать основу в качестве элемента ремонта в канбане!");
		Возврат;
		КонецЕсли; 
	ИначеЕсли НР.ВидЭлемента <> Перечисления.ВидыЭлементовНормРасходов.Материал Тогда
		Если Не НР.Элемент.Канбан.Пустая() Тогда
			Если НР.Элемент.Канбан.Служебный Тогда
			Сообщить("Запрещено выбирать служебный канбан в качестве элемента ремонта!");
			Возврат;			
			ИначеЕсли ОбщийМодульВызовСервера.КанбанПринадлежитЛинейке(Объект.Линейка,НР.Элемент) Тогда
			Сообщить("Запрещено выбирать собственный полуфабрикат линейки в качестве элемента ремонта!");
			Возврат;
			КонецЕсли; 
		КонецЕсли;
	КонецЕсли;
ТЧ = Объект.ЭлементыРемонта.Добавить();
ТЧ.НР = НР; 
	Если ТипЗнч(НР) = Тип("СправочникСсылка.НормыРасходов") Тогда
	ТЧ.Спецификация = НР.Владелец;
	ТЧ.Позиция = НР.Позиция;
	Иначе
	ТЧ.Спецификация = НР.Владелец.Владелец;
	ТЧ.Позиция = НР.Владелец.Позиция;	
	КонецЕсли; 
ТЧ.Элемент = НР.Элемент;
ТЧ.Количество = РегистрыСведений.НормыРасходов.ПолучитьПоследнее(ПолучитьДатуЗапускаПЗ(),Новый Структура("НормаРасходов",НР)).Норма;   
ТЧ.ОсновнаяЕдиницаИзмерения = ТЧ.Элемент.ОсновнаяЕдиницаИзмерения; 
ЭтаФорма.Модифицированность = Истина;
КонецПроцедуры 

&НаКлиенте
Процедура ДеревоСпецификацииВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
ДобавитьЭлементРемонтаНаСервере(Элемент.ТекущиеДанные.НормаРасходов);
КонецПроцедуры

&НаСервере
Функция ПолучитьПустоеЗначениеНормРасходов()
Возврат(Справочники.НормыРасходов.ПустаяСсылка());
КонецФункции

&НаСервере
Функция РемонтЗавершен()
	Если Объект.Статус = Перечисления.СтатусыРемонта.Окончен Тогда
	Возврат(Истина);
	Иначе
	Возврат(Ложь);
	КонецЕсли; 
КонецФункции

&НаСервере
Функция ЭтоСобственныйРемонт()
Возврат(?(Объект.ВидРемонта = Перечисления.ВидыРемонта.Собственный,Истина,Ложь));
КонецФункции

&НаСервере
Функция ЭтоДилерскийРемонт()
Возврат(?(Объект.ВидРемонта = Перечисления.ВидыРемонта.Дилерский,Истина,Ложь));
КонецФункции

&НаСервере
Функция ЭтоРемонтБракаКанбан()
Возврат(?(Объект.ВидРемонта = Перечисления.ВидыРемонта.БракКанбан,Истина,Ложь));
КонецФункции

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
		Если РемонтЗавершен() Тогда
		Элементы.Группа5.Доступность = Ложь;
		Иначе
			Если ЭтоСобственныйРемонт() Тогда
			Элементы.Отложить.Доступность = Ложь;
			Элементы.Завершить.Доступность = Истина;
			Элементы.ЭлементыРемонтаБракПоставщика.Видимость = Ложь;
			КонецЕсли; 
		КонецЕсли; 
			Если ОбщийМодульВызовСервера.ДоступностьРоли("Администратор") Тогда
			Элементы.Группа9.ТолькоПросмотр = Ложь;
			Элементы.Группа5.Доступность = Истина;
			КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьДатуЗапускаПЗ()
	Если Объект.ПроизводственноеЗадание <> Неопределено Тогда
		Если ТипЗнч(Объект.ПроизводственноеЗадание) = Тип("ДокументСсылка.ПроизводственноеЗадание") Тогда	
		Возврат(Объект.ПроизводственноеЗадание.ДатаЗапуска);
		Иначе
		Возврат(Объект.ПроизводственноеЗадание.ДокументОснование.ДатаЗапуска);
		КонецЕсли;
	Иначе
	Возврат(ТекущаяДата());
	КонецЕсли; 
КонецФункции

&НаСервере
Процедура ОтложитьНаСервере()
	Если Объект.ДатаОтложен = Дата(1,1,1) Тогда
	Объект.ДатаОтложен = ТекущаяДата();
	КонецЕсли;
Объект.Статус = Перечисления.СтатусыРемонта.Отложен;
КонецПроцедуры

&НаКлиенте
Процедура Отложить(Команда)
	//Если Объект.ЭлементыРемонта.Количество() > 0 Тогда
	ОтложитьНаСервере();
	//Иначе
	//	Если Вопрос("Не выбраны элементы ремонта! 
	//				|Карточка ремонта будет закрыта без изменения статуса ремонта!", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Нет Тогда
	//	Возврат;
	//	КонецЕсли; 	
	//КонецЕсли;
Записать();
КонецПроцедуры

&НаСервере
Процедура ЗавершитьНаСервере() 
Объект.Статус = Перечисления.СтатусыРемонта.Окончен;
	Если Объект.ДатаОкончания = Дата(1,1,1) Тогда
	Объект.ДатаОкончания = ТекущаяДата();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПроверитьЗаполнениеЭлементовРемонта()
	Если Объект.ЭлементыРемонта.Количество() = 0 Тогда
	Сообщить("Выберите элементы ремонта!");
	Возврат Ложь;
	КонецЕсли;
Результат = Истина;
	Для каждого ТЧ Из Объект.ЭлементыРемонта Цикл
		Если ТЧ.ВидНеисправности.Пустая() Тогда
		Сообщить(СокрЛП(ТЧ.Элемент.Наименование)+" - не выбран вид неисправности!");
		Результат = Ложь;
		ИначеЕсли ТЧ.ЗаменаЭлемента и (Не ЗначениеЗаполнено(ТЧ.Документ)) Тогда
  		Сообщить(СокрЛП(ТЧ.Элемент.Наименование)+" - не создан документ перемещения (списания) МПЗ для замены!");
		Результат = Ложь;
		КонецЕсли; 
	КонецЦикла;
Возврат(Результат);
КонецФункции

&НаКлиенте
Процедура Завершить(Команда)
	Если ПроверитьЗаполнениеЭлементовРемонта() Тогда
		Если ЭтоРемонтБракаКанбан() Тогда
		КоличествоНеремонтопригодных = 0;
			Если ВвестиЧисло(КоличествоНеремонтопригодных,"Введите кол-во неремонтопригодных изделий",9,3) Тогда
				Если КоличествоНеремонтопригодных > Объект.Количество Тогда
				Сообщить("Неремонтопригодных изделий не может быть больше кол-ва изделий в ремонте!");
				Возврат;
				КонецЕсли; 
			Объект.КоличествоНеремонтопригодных = КоличествоНеремонтопригодных;
			Иначе
			Возврат;
			КонецЕсли;
		КонецЕсли; 	
	ЗавершитьНаСервере();
	ЭтаФорма.Модифицированность = Истина;
	Записать();		
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПолучитьРМ()
Возврат(СокрЛП(Объект.РабочееМесто.Наименование));
КонецФункции

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	Если ПараметрыЗаписи.Свойство("НеЗакрывать") Тогда
	Возврат;	
	КонецЕсли;
ТекСтатус = ПолучитьСтатусНаСервере();
	Если ТекСтатус = 2 Тогда
	ПоказатьОповещениеПользователя("ВНИМАНИЕ!",,"Передайте изделия на "+ПолучитьРМ(),БиблиотекаКартинок.Пользователь);
	КонецЕсли; 
ЭтаФорма.Закрыть(ПолучитьСтатусНаСервере());
КонецПроцедуры

&НаКлиенте
Процедура ПередЗакрытием(Отказ, СтандартнаяОбработка)
	Если ОбщийМодульВызовСервера.ДоступностьРоли("Администратор") Тогда
		Если Не МожноЗакрытьФорму() Тогда
			Если Вопрос("Закрыть форму без изменения статуса?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
			Отказ = Ложь;
			Иначе
			Отказ = Истина;
			КонецЕсли; 
		КонецЕсли; 
	Иначе
	Отказ = Не МожноЗакрытьФорму();
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция МожноЗакрытьФорму()
	Если Объект.ЭлементыРемонта.Количество() > 0 Тогда
		Если Объект.ВидРемонта = Перечисления.ВидыРемонта.Собственный Тогда
			Если Объект.Статус = Перечисления.СтатусыРемонта.Окончен Тогда
			Возврат(Истина);
			Иначе
			Сообщить("Собственный ремонт должен быть завершён!");
			Возврат(Ложь);
			КонецЕсли;
		Иначе
			Если Объект.Статус <> Перечисления.СтатусыРемонта.Ремонт Тогда
			Возврат(Истина);
			Иначе
			Сообщить("Ремонт должен быть отложен или завершён!");
			Возврат(Ложь);
			КонецЕсли; 
		КонецЕсли;
	Иначе
	Возврат(Истина);
	КонецЕсли; 	
КонецФункции

&НаКлиенте
Процедура СтандартныйКомментарийНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
СтандартнаяОбработка = Ложь;
Ф = ПолучитьФорму("Справочник.КомментарииНеисправностей.ФормаВыбора");
Ф.Список.Параметры.УстановитьЗначениеПараметра("РабочееМесто",Объект.РабочееМесто);
Результат = Ф.ОткрытьМодально();
	Если Результат <> Неопределено Тогда
	Объект.СтандартныйКомментарий = Результат;
	КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция ПолучитьПроизводственноеЗадание()
	Если Объект.ПроизводственноеЗадание <> Неопределено Тогда
		Если ТипЗнч(Объект.ПроизводственноеЗадание) = Тип("ДокументСсылка.ПроизводственноеЗадание") Тогда	
		Возврат(Объект.ПроизводственноеЗадание);
		Иначе
		Возврат(Объект.ПроизводственноеЗадание.ДокументОснование);
		КонецЕсли;
	Иначе
	Возврат(Неопределено);
	КонецЕсли;
КонецФункции 

&НаКлиенте
Процедура ПечатьСпецификации(Команда)
П = Новый Структура("ПЗ",ПолучитьПроизводственноеЗадание());
ОткрытьФорму("Отчет.ПечатьСпецификации.Форма.ФормаОтчета",П);
КонецПроцедуры

&НаСервере
Функция ЭтоКанбан(Элемент)
Возврат(Не Элемент.Канбан.Пустая());
КонецФункции

&НаСервере
Функция ПриЗаменеСоздаватьМТК(МПЗ)
Возврат(МПЗ.Канбан.ПриЗаменеСоздаватьМТК);
КонецФункции

&НаСервере
Функция СоздатьРемонтнуюМТК(Линейка,Стр)
ТЧ = Объект.ЭлементыРемонта.НайтиПоИдентификатору(Стр);
СтдКомментарий = Справочники.СтандартныеКомментарии.НайтиПоНаименованию("Полуфабрикаты, созданные по заказу ремонтника",Истина);				
Возврат(ОбщийМодульСозданиеДокументов.СоздатьМТК(Линейка,ТЧ.НовыйЭлемент.Элемент,ТЧ.Количество,СтдКомментарий,Справочники.Проекты.ПустаяСсылка(),Истина,Ложь));
КонецФункции

&НаСервере
Функция ПолучитьЛинейкуИзготовленияКанбана(МПЗ)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЛинейкиЛинейкиПотребители.Ссылка
	|ИЗ
	|	Справочник.Линейки.ЛинейкиПотребители КАК ЛинейкиЛинейкиПотребители
	|ГДЕ
	|	ЛинейкиЛинейкиПотребители.Линейка = &Линейка";
Запрос.УстановитьПараметр("Линейка", Объект.Линейка);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		Если ОбщийМодульВызовСервера.КанбанПринадлежитЛинейке(ВыборкаДетальныеЗаписи.Ссылка,МПЗ) Тогда	
		Возврат(ВыборкаДетальныеЗаписи.Ссылка);
		КонецЕсли; 
	КонецЦикла;
Возврат(Неопределено);
КонецФункции

&НаСервере
Функция ПолучитьПустуюМТК()
Возврат(Документы.МаршрутнаяКарта.ПустаяСсылка());
КонецФункции

&НаСервере
Функция ЭтоРемонтКанбан()
Возврат(?(Объект.ВидРемонта = Перечисления.ВидыРемонта.Канбан,Истина,Ложь));
КонецФункции

&НаКлиенте
Процедура ЭлементыРемонтаЗаменаЭлементаПриИзменении(Элемент)
	Если Элементы.ЭлементыРемонта.ТекущиеДанные.НР = Неопределено Тогда
	Сообщить("Данные старой версии. Удалите строку и выберите снова этот же элемент ремонта!");
	Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
	Возврат;	
	ИначеЕсли Элементы.ЭлементыРемонта.ТекущиеДанные.ВидНеисправности.Пустая() Тогда
	сп = Новый СообщениеПользователю;
	сп.Текст = "Не заполнен вид неисправности!";
	сп.КлючДанных = Объект.Ссылка;
	сп.Поле = "ЭлементыРемонта["+Элементы.ЭлементыРемонта.ТекущаяСтрока+"].ВидНеисправности";
	сп.ПутьКДанным = "Объект";
	сп.Сообщить();
	Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
	Возврат;
	КонецЕсли; 
		Если Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Истина Тогда
			Если ТипЗнч(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если Не ЭтоКанбан(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент) Тогда
					Если ЭтоРемонтКанбан() Тогда
					Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
					Сообщить("Запрещено заменять МПЗ без признака канбана!");
					Возврат;					
					Иначе	
					Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Элементы.ЭлементыРемонта.ТекущиеДанные.НР;
					Результат = СоздатьРемонтнуюМТК(Объект.Линейка,Элементы.ЭлементыРемонта.ТекущаяСтрока);
						Если Не Результат.Пустая() Тогда					
						Элементы.ЭлементыРемонта.ТекущиеДанные.МТК = Результат;
						ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
						Иначе
						Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Неопределено;
						Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
						Сообщить("Ремонтная МТК не создана!");
						КонецЕсли; 
					Возврат;					
					КонецЕсли; 
				КонецЕсли; 
			КонецЕсли;
		Результат = ОткрытьФормуМодально("ОбщаяФорма.ЗаменаЭлементаПриРемонте",Новый Структура("Ссылка,НормаРасходов,ВидНеисправности,Количество",Объект.Ссылка,Элементы.ЭлементыРемонта.ТекущиеДанные.НР,Элементы.ЭлементыРемонта.ТекущиеДанные.ВидНеисправности,Элементы.ЭлементыРемонта.ТекущиеДанные.Количество));
			Если Результат <> Неопределено Тогда
			Элементы.ЭлементыРемонта.ТекущиеДанные.БракПоставщика = Результат.БракПоставщика;	
			Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Результат.НовыйЭлемент;
			Элементы.ЭлементыРемонта.ТекущиеДанные.Документ = Результат.Документ;
					Если Не ЭтоРемонтКанбан() Тогда
						Если Не ЗначениеЗаполнено(Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент) Тогда
							Если ТипЗнч(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент) = Тип("СправочникСсылка.Номенклатура") Тогда
								Если ЭтоКанбан(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент) Тогда
									Если ПриЗаменеСоздаватьМТК(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент) Тогда
									Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Элементы.ЭлементыРемонта.ТекущиеДанные.НР;
									Линейка = ПолучитьЛинейкуИзготовленияКанбана(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент);
										Если Линейка <> Неопределено Тогда
										Результат = СоздатьРемонтнуюМТК(Линейка,Элементы.ЭлементыРемонта.ТекущаяСтрока);
											Если Не Результат.Пустая() Тогда					
											Элементы.ЭлементыРемонта.ТекущиеДанные.МТК = Результат;
											ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
											Иначе
											Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Неопределено;
											Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
											Сообщить("Ремонтная МТК не создана!");
											КонецЕсли;
										Иначе
										Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Неопределено;
										Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
										Сообщить("Не найдена линейка канбана! Ремонтная МТК не создана!");
										КонецЕсли; 
									КонецЕсли; 
								КонецЕсли; 
							КонецЕсли;
						КонецЕсли;				
					КонецЕсли; 
			ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
			Иначе
			Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Ложь;
			КонецЕсли;  
		Иначе
			Если ЗначениеЗаполнено(Элементы.ЭлементыРемонта.ТекущиеДанные.МТК) Тогда	
				Если Вопрос("Открыта ремонтная МТК!
							|Вы хотите отменить замену?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Нет Тогда
				Результат = ОткрытьФормуМодально("ОбщаяФорма.ЗаменаЭлементаПриРемонте",Новый Структура("Ссылка,НормаРасходов,ВидНеисправности,Количество",Объект.Ссылка,Элементы.ЭлементыРемонта.ТекущиеДанные.НР,Элементы.ЭлементыРемонта.ТекущиеДанные.ВидНеисправности,Элементы.ЭлементыРемонта.ТекущиеДанные.Количество));
					Если Результат <> Неопределено Тогда
					Элементы.ЭлементыРемонта.ТекущиеДанные.БракПоставщика = Результат.БракПоставщика;
					Элементы.ЭлементыРемонта.ТекущиеДанные.Документ = Результат.Документ;
					ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
					КонецЕсли;
				Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Истина;
				Возврат;
				КонецЕсли; 
			КонецЕсли; 
				Если (ЗначениеЗаполнено(Элементы.ЭлементыРемонта.ТекущиеДанные.Документ))или(ЗначениеЗаполнено(Элементы.ЭлементыРемонта.ТекущиеДанные.МТК)) Тогда
					Если Вопрос("При отмене замены элемента ремонта будут удалены документы, связанные с ним!
								|Вы действительно хотите отменить замену?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
						Если Не УдалитьСвязанныеДокументы(Элементы.ЭлементыРемонта.ТекущаяСтрока) Тогда
						Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Истина;
						Возврат;	
						КонецЕсли;				 
					Иначе
					Элементы.ЭлементыРемонта.ТекущиеДанные.ЗаменаЭлемента = Истина;
					Возврат;	
					КонецЕсли;	
				КонецЕсли;
		Элементы.ЭлементыРемонта.ТекущиеДанные.МТК = ПолучитьПустуюМТК();
		Элементы.ЭлементыРемонта.ТекущиеДанные.Документ = Неопределено;
		Элементы.ЭлементыРемонта.ТекущиеДанные.БракПоставщика = Ложь;
		Элементы.ЭлементыРемонта.ТекущиеДанные.НовыйЭлемент = Неопределено;
		ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
		КонецЕсли; 
КонецПроцедуры

&НаСервере
Функция УдалитьСвязанныеДокументы(Стр)
ТЧ = Объект.ЭлементыРемонта.НайтиПоИдентификатору(Стр);
	Попытка
	НачатьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция + 1;	
		Если ЗначениеЗаполнено(ТЧ.Документ) Тогда
			Если Не ОбщийМодульВызовСервера.УдалитьЦепочкуДокументов(ТЧ.Документ) Тогда
			ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
			Возврат(Ложь); 
			КонецЕсли;
		КонецЕсли;
			Если ЗначениеЗаполнено(ТЧ.МТК) Тогда
				Если ТЧ.МТК.Статус <> 0 Тогда
				Сообщить("Ремонтная МТК находится в работе и не может быть удалена! Обратитесь к мастеру соответствующей линейки!");
				ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
				Возврат(Ложь); 
				КонецЕсли; 
			Запрос = Новый Запрос;

			Запрос.Текст = 
				"ВЫБРАТЬ
				|	ПроизводственноеЗадание.Ссылка
				|ИЗ
				|	Документ.ПроизводственноеЗадание КАК ПроизводственноеЗадание
				|ГДЕ
				|	ПроизводственноеЗадание.ДокументОснование = &ДокументОснование";
			Запрос.УстановитьПараметр("ДокументОснование", ТЧ.МТК);
			РезультатЗапроса = Запрос.Выполнить();
			ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
				Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
				ПЗ = ВыборкаДетальныеЗаписи.Ссылка.ПолучитьОбъект();		
				ПЗ.Удалить();
				КонецЦикла;
			МТК = ТЧ.МТК.ПолучитьОбъект();
			МТК.Удалить();
			КонецЕсли;
	ЗафиксироватьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;Если ПараметрыСеанса.АктивнаТранзакция = 0 тогда СРМ_ОбменВебСервис.ОтправкаПослеТранзакции();КонецЕсли;
	Возврат(Истина);
	Исключение
	Сообщить(ОписаниеОшибки());
	ОтменитьТранзакцию();ПараметрыСеанса.АктивнаТранзакция = ПараметрыСеанса.АктивнаТранзакция-1;ПараметрыСеанса.ОбъектыСозданныеВТранзакции = Новый ХранилищеЗначения(Новый Массив);
	Возврат(Ложь); 
	КонецПопытки;
КонецФункции

&НаКлиенте
Процедура ЭлементыРемонтаПередУдалением(Элемент, Отказ)
	Если (ЗначениеЗаполнено(Элементы.ЭлементыРемонта.ТекущиеДанные.Документ))или(ЗначениеЗаполнено(Элементы.ЭлементыРемонта.ТекущиеДанные.МТК)) Тогда
		Если Вопрос("При удалении строки будут удалены документы, связанные с этим элементом ремонта!
					|Вы действительно хотите удалить строку?", РежимДиалогаВопрос.ДаНет) = КодВозвратаДиалога.Да Тогда
			Если УдалитьСвязанныеДокументы(Элементы.ЭлементыРемонта.ТекущаяСтрока) Тогда
			Элементы.ЭлементыРемонта.ТекущиеДанные.МТК = ПолучитьПустуюМТК();
			Элементы.ЭлементыРемонта.ТекущиеДанные.Документ = Неопределено;
			Иначе
			Отказ = Истина;
			КонецЕсли;				 
		Иначе
		Отказ = Истина;	
		КонецЕсли;	
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ЭлементыРемонтаПослеУдаления(Элемент)
ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
КонецПроцедуры

&НаСервере
Функция ПроверитьВидНеисправности(МПЗ,ВидНеисправности)
	Если ВидНеисправности.ПеремещатьНаСкладПоставщика Тогда
		Если ТипЗнч(МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда
			Если Не МПЗ.Канбан.Пустая() Тогда
				Если МПЗ.Канбан.Подразделение = Объект.Линейка.Подразделение Тогда
				Возврат(Ложь);
				КонецЕсли; 
			КонецЕсли; 
		КонецЕсли;
	КонецЕсли;  
Возврат(Истина);
КонецФункции

&НаКлиенте
Процедура ЭлементыРемонтаВидНеисправностиОбработкаВыбора(Элемент, ВыбранноеЗначение, СтандартнаяОбработка)
	Если Не ПроверитьВидНеисправности(Элементы.ЭлементыРемонта.ТекущиеДанные.Элемент,ВыбранноеЗначение) Тогда
	Сообщить("Для собственных полуфабрикатов запрещено выбирать этот вид неисправности!");
	СтандартнаяОбработка = Ложь; 
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ЭлементыРемонтаБракПоставщикаПриИзменении(Элемент)
ЭлементыРемонтаБракПоставщикаПриИзмененииНаСервере(Элементы.ЭлементыРемонта.ТекущаяСтрока);
КонецПроцедуры

&НаСервере
Процедура ЭлементыРемонтаБракПоставщикаПриИзмененииНаСервере(Стр)
ТЧ = Объект.ЭлементыРемонта.НайтиПоИдентификатору(Стр);
	Если ТЧ.БракПоставщика Тогда
		Если ТЧ.ЗаменаЭлемента Тогда
			Если ТипЗнч(ТЧ.Элемент) = Тип("СправочникСсылка.Номенклатура") Тогда
				Если ТЧ.Элемент.Канбан.Пустая() Тогда
				Сообщить("Выставляется только для канбанов!");				
				ТЧ.БракПоставщика = Ложь;
				КонецЕсли; 
			КонецЕсли; 
		Иначе
		Сообщить("Выставляется только при замене элемента!");
		ТЧ.БракПоставщика = Ложь;
		КонецЕсли; 	
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ВыбратьЭлементРемонта(Команда)
ДобавитьЭлементРемонтаНаСервере(Элементы.ДеревоСпецификации.ТекущиеДанные.НормаРасходов);
ЭтаФорма.Модифицированность = Истина;
КонецПроцедуры

&НаСервере
Процедура НайтиВДереве(КоллекцияСтрокДереваОдногоУровня) 
    Для Каждого Стр Из КоллекцияСтрокДереваОдногоУровня Цикл
        Если ВРег(СокрЛП(Стр.Позиция)) = ВРег(СокрЛП(СтрокаПоиска)) Тогда
       	СписокИдентификаторов.Добавить(Стр.ПолучитьИдентификатор());
        КонецЕсли;
    НайтиВДереве(Стр.ПолучитьЭлементы());
    КонецЦикла;   
КонецПроцедуры

&НаСервере
Процедура НайтиПоПозицииНаСервере() 
НайтиВДереве(ДеревоСпецификации.ПолучитьЭлементы());
	Если СписокИдентификаторов.Количество() > 0 Тогда
	Элементы.ДеревоСпецификации.ТекущаяСтрока =  СписокИдентификаторов[0].Значение;
	КонецЕсли; 
КонецПроцедуры 

&НаКлиенте
Процедура НайтиПоПозиции(Команда)
СписокИдентификаторов.Очистить();
	Если ВвестиСтроку(СтрокаПоиска,"Введите позицию для поиска",100,Ложь) Тогда
	НайтиПоПозицииНаСервере();
	КонецЕсли; 
ЭтаФорма.ТекущийЭлемент = Элементы.ДеревоСпецификации;
КонецПроцедуры

&НаКлиенте
Процедура НайтиДалее(Команда)
ВыбЗнач = СписокИдентификаторов.НайтиПоЗначению(Элементы.ДеревоСпецификации.ТекущаяСтрока);
	Если СписокИдентификаторов.Количество() > 0 Тогда
		Если ВыбЗнач <> Неопределено Тогда
			Если СписокИдентификаторов.Индекс(ВыбЗнач) = СписокИдентификаторов.Количество() - 1 Тогда
			Иден = -1;		
			Иначе	
			Иден = ВыбЗнач.ПолучитьИдентификатор();		
			КонецЕсли;
		Иначе
		Иден = -1;		
		КонецЕсли; 
	КонецЕсли; 
	Для каждого Стр Из СписокИдентификаторов Цикл
		Если Стр.ПолучитьИдентификатор() > Иден Тогда
		Элементы.ДеревоСпецификации.ТекущаяСтрока = Стр.Значение;
		Прервать;		
		КонецЕсли; 
	КонецЦикла;
ЭтаФорма.ТекущийЭлемент = Элементы.ДеревоСпецификации; 	 
КонецПроцедуры

&НаСервере
Процедура НайтиВДеревеПоМПЗ(КоллекцияСтрокДереваОдногоУровня) 
    Для Каждого Стр Из КоллекцияСтрокДереваОдногоУровня Цикл
        Если Найти(ВРег(Стр.МПЗ),ВРег(СокрЛП(СтрокаПоиска))) > 0 Тогда
       	СписокИдентификаторов.Добавить(Стр.ПолучитьИдентификатор());
        КонецЕсли;
	НайтиВДеревеПоМПЗ(Стр.ПолучитьЭлементы());
    КонецЦикла;   
КонецПроцедуры

&НаСервере
Процедура НайтиПоСочитаниюНаСервере() 
НайтиВДеревеПоМПЗ(ДеревоСпецификации.ПолучитьЭлементы());
	Если СписокИдентификаторов.Количество() > 0 Тогда
	Элементы.ДеревоСпецификации.ТекущаяСтрока =  СписокИдентификаторов[0].Значение;
	КонецЕсли; 
КонецПроцедуры 

&НаКлиенте
Процедура НайтиПоСочетанию(Команда)
СписокИдентификаторов.Очистить();
	Если ВвестиСтроку(СтрокаПоиска,"Введите строку для поиска",100,Ложь) Тогда
	НайтиПоСочитаниюНаСервере();
	КонецЕсли;
ЭтаФорма.ТекущийЭлемент = Элементы.ДеревоСпецификации; 
КонецПроцедуры

&НаКлиенте
Процедура ПереместитьИзделиеВБрак(Команда)
КолБрак = ОткрытьФормуМодально("ОбщаяФорма.ОформлениеБракаКанбан",Новый Структура("РабочееМесто,ПЗ,КоличествоИзделия,Ремонт",Объект.РабочееМесто,Объект.ПроизводственноеЗадание,Объект.Количество,Истина)); 
	Если КолБрак > 0 Тогда
	Объект.Количество = Объект.Количество - КолБрак;
	ЭтаФорма.Записать(Новый Структура("НеЗакрывать",Истина));
	ПоказатьОповещениеПользователя("ВНИМАНИЕ!",,"Передайте бракованные изделия мастеру",БиблиотекаКартинок.Пользователь);		
	КонецЕсли;  
КонецПроцедуры

&НаКлиенте
Процедура ЭлементыРемонтаВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
   Если Поле.Имя = "ЭлементыРемонтаДокумент" Тогда
   Документ = Элементы.ЭлементыРемонта.ТекущиеДанные.Документ;
        Если ЗначениеЗаполнено(Документ) Тогда
		ОткрытьЗначение(Документ);
        КонецЕсли;
    КонецЕсли;
КонецПроцедуры

&НаСервере
Функция ПечатьЗаменаЭлементовРемонтаНаСервере()
ТабДок = Новый ТабличныйДокумент;

ОбъектЗн = РеквизитФормыВЗначение("Объект");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапка = Макет.ПолучитьОбласть("Шапка");
ОблСтрока = Макет.ПолучитьОбласть("Строка");

ОблШапка.Параметры.ДокументРемонта = Объект.ПроизводственноеЗадание; 
ТабДок.Вывести(ОблШапка);
	Для каждого ТЧ Из Объект.ЭлементыРемонта Цикл
		Если ЗначениеЗаполнено(ТЧ.Документ) Тогда
			Для каждого ТЧ_МПЗ Из ТЧ.Документ.ТабличнаяЧасть Цикл
			ОблСтрока.Параметры.МПЗ = СокрЛП(ТЧ_МПЗ.МПЗ.Наименование);
			ОблСтрока.Параметры.Количество = ТЧ_МПЗ.Количество;
  			ОблСтрока.Параметры.ЕдиницаИзмерения = СокрЛП(ТЧ_МПЗ.ЕдиницаИзмерения.Наименование);
  			ОблСтрока.Параметры.Документ = ТЧ.Документ;
  			ОблСтрока.Параметры.МестоХранения = СокрЛП(ТЧ.Документ.МестоХранения.Наименование);
			ТабДок.Вывести(ОблСтрока);
			КонецЦикла;
		КонецЕсли;	
	КонецЦикла; 
Возврат(ТабДок);
КонецФункции

&НаКлиенте
Процедура ПечатьЗаменаЭлементовРемонта(Команда)
ТД = ПечатьЗаменаЭлементовРемонтаНаСервере();
ТД.Показать("Перечень замен элементов ремонта");
КонецПроцедуры

&НаСервере
Процедура СчитатьIMEIНаСервере(IMEI)
	Если Не Объект.ПроизводственноеЗадание.Пустая() Тогда
		Попытка				
		НаборЗаписей = РегистрыСведений.БарКоды.СоздатьНаборЗаписей();
		НаборЗаписей.Отбор.ПЗ.Установить(Объект.ПроизводственноеЗадание);
		НаборЗаписей.Прочитать();
		    Для Каждого Запись Из НаборЗаписей Цикл 
			Запись.IMEI = IMEI; 
		    КонецЦикла;
		НаборЗаписей.Записать(Истина);
		Сообщить("Присвоен новый код IMEI: "+IMEI);
		Исключение
		Сообщить(ОписаниеОшибки());
		КонецПопытки;
	Иначе
	Сообщить("Нет производственного задания!");
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура СчитатьIMEI(Команда,КодIMEI = "")
	Если Не ЗначениеЗаполнено(КодIMEI) Тогда
		Если Не ВвестиСтроку(КодIMEI,"Введите IMEI",0) Тогда
		Возврат;
		КонецЕсли; 		
	КонецЕсли;  
		Если Найти(КодIMEI,"IMEI:") > 0 Тогда
		КодIMEI = Сред(КодIMEI,Найти(КодIMEI,"IMEI:")+5);
		IMEI = Лев(КодIMEI,Найти(КодIMEI,";")-1);
		Иначе	
		IMEI = КодIMEI;
		КонецЕсли;
			Если ЗначениеЗаполнено(IMEI) Тогда
			СчитатьIMEIНаСервере(IMEI);
			Иначе
			Сообщить("Введите код IMEI!");
			КонецЕсли;	
КонецПроцедуры

&НаКлиенте
Процедура ВнешнееСобытие(Источник, Событие, Данные)
СчитатьIMEI(Неопределено,СокрЛП(Данные));
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
ПоддерживаемыеТипыВО = Новый Массив();
ПоддерживаемыеТипыВО.Добавить("СканерШтрихкода");
МенеджерОборудованияКлиент.ОтключитьОборудованиеПоТипу(УникальныйИдентификатор, ПоддерживаемыеТипыВО);
КонецПроцедуры
