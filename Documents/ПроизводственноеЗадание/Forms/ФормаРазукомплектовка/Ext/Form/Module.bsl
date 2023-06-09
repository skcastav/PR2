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
Процедура ПолучитьСписокЭлементовСпецификации(Спецификация,КолУзла,СтрЭтап)
ТаблицаМПЗ = Новый ТаблицаЗначений;

ТаблицаМПЗ.Колонки.Добавить("НР",Новый ОписаниеТипов("СправочникСсылка.НормыРасходов"));
ТаблицаМПЗ.Колонки.Добавить("Норма");
ТаблицаМПЗ.Колонки.Добавить("ПозицияСортировка",Новый ОписаниеТипов("Строка",Новый КвалификаторыСтроки(100)));

Основа = Справочники.НормыРасходов.ПустаяСсылка();
НР = ОбщийМодульВызовСервера.ПолучитьНормыРасходовПоВладельцу_Н_М(Спецификация,Параметры.ПроизводственноеЗадание.ДатаЗапуска);
	Пока НР.Следующий() Цикл	
		Если ТипЗнч(НР.Элемент) = Тип("СправочникСсылка.Номенклатура") Тогда
			Если НР.ВидЭлемента = Перечисления.ВидыЭлементовНормРасходов.Основа Тогда
			Основа = НР.Ссылка;
			НормаОснова = НР.Норма;
			Иначе
			Стр = СтрЭтап.Строки.Добавить();
			ВыбАналог = Параметры.ПроизводственноеЗадание.Аналоги.НайтиСтроки(Новый Структура("Спецификация,НормаРасходов",Спецификация,НР.Ссылка));
				Если ВыбАналог.Количество() > 0 Тогда
				АналогНР = ВыбАналог[0].АналогНормыРасходов;
				НормыАНР = ОбщегоНазначенияПовтИсп.АналогиНормРасходов_ПолучитьПоследнее(АналогНР,Параметры.ПроизводственноеЗадание.ДатаЗапуска);
				Стр.НормаРасходов = АналогНР;
				Стр.ВидМПЗ = АналогНР.ВидЭлемента;
				Стр.МПЗ = АналогНР.Элемент;
				Стр.Количество = НормыАНР.Норма*КолУзла;
					Если АналогНР.ВидЭлемента <> Перечисления.ВидыЭлементовНормРасходов.Материал Тогда
					Стр.Канбан = АналогНР.Элемент.Канбан;
					КонецЕсли; 
				Стр.Аналог = Истина;
				Иначе
				Стр.НормаРасходов = НР.Ссылка;
				Стр.ВидМПЗ = НР.ВидЭлемента;
				Стр.МПЗ = НР.Элемент;
				Стр.Количество = НР.Норма*КолУзла;
				Стр.Канбан = НР.Элемент.Канбан;
				КонецЕсли;
			Стр.Позиция = НР.Позиция;
			Стр.ЭтапСпецификации = Спецификация;
				Если Не ЗначениеЗаполнено(НР.Элемент.Канбан) Тогда
				ПолучитьСписокЭлементовСпецификации(НР.Элемент,ПолучитьБазовоеКоличество(НР.Норма,НР.Элемент.ОсновнаяЕдиницаИзмерения),Стр);
				КонецЕсли; 
			КонецЕсли;
		Иначе
		ТЧ = ТаблицаМПЗ.Добавить();
		ТЧ.НР = НР.Ссылка;
		ТЧ.Норма = НР.Норма;			
		ТЧ.ПозицияСортировка = СортироватьПоПорядку(СокрЛП(НР.Позиция));
		КонецЕсли;
	КонецЦикла;	
		Если Не Основа.Пустая() Тогда
		Стр = СтрЭтап.Строки.Добавить();
		Стр.НормаРасходов = Основа;
		Стр.ВидМПЗ = Основа.ВидЭлемента;
		Стр.МПЗ = Основа.Элемент;
		Стр.Количество = НормаОснова*КолУзла;
		Стр.Канбан = Основа.Элемент.Канбан;
		Стр.ЭтапСпецификации = Спецификация;
		ПолучитьСписокЭлементовСпецификации(Основа.Элемент,ПолучитьБазовоеКоличество(НормаОснова,Основа.Элемент.ОсновнаяЕдиницаИзмерения),Стр);
		КонецЕсли;
ТаблицаМПЗ.Сортировать("ПозицияСортировка");
	Для каждого ТЧ Из ТаблицаМПЗ Цикл
	Стр = СтрЭтап.Строки.Добавить();
	ВыбАналог = Параметры.ПроизводственноеЗадание.Аналоги.НайтиСтроки(Новый Структура("Спецификация,НормаРасходов",Спецификация,ТЧ.НР));
		Если ВыбАналог.Количество() > 0 Тогда
		АналогНР = ВыбАналог[0].АналогНормыРасходов;
		Стр.НормаРасходов = АналогНР;
		Стр.ВидМПЗ = АналогНР.ВидЭлемента;
		Стр.МПЗ = АналогНР.Элемент;
		Стр.Количество = ТЧ.Норма*КолУзла;
		Стр.Аналог = Истина;
		Иначе
		Стр.НормаРасходов = ТЧ.НР;
		Стр.ВидМПЗ = ТЧ.НР.ВидЭлемента;
		Стр.МПЗ = ТЧ.НР.Элемент;
		Стр.Количество = ТЧ.Норма*КолУзла;
		КонецЕсли;
	Стр.Позиция = ТЧ.НР.Позиция;
	Стр.ЭтапСпецификации = Спецификация;
	КонецЦикла; 
КонецПроцедуры

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
тДеревоСпецификации = РеквизитФормыВЗначение("ДеревоСпецификации");
СтрСпец = тДеревоСпецификации.Строки.Добавить();
СтрСпец.МПЗ = Параметры.Изделие;
СтрСпец.Количество = Параметры.Количество;
СтрСпец.Канбан = Параметры.Изделие.Канбан;
СтрСпец.ЭтапСпецификации = Параметры.Изделие;
ПолучитьСписокЭлементовСпецификации(Параметры.Изделие,Параметры.Количество,СтрСпец);
ЗначениеВРеквизитФормы(тДеревоСпецификации, "ДеревоСпецификации");
КонецПроцедуры

&НаКлиенте
Процедура РазвернутьДерево()
тЭлементы = ДеревоСпецификации.ПолучитьЭлементы();
   Для Каждого тСтр Из тЭлементы Цикл 
   Элементы.ДеревоСпецификации.Развернуть(тСтр.ПолучитьИдентификатор(), Истина);
   КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СвернутьДерево()
тЭлементы = ДеревоСпецификации.ПолучитьЭлементы();
СвернутьРекурсия(тЭлементы);
КонецПроцедуры
 
&НаКлиенте
Процедура СвернутьРекурсия(тЭлементы)
	Для Каждого тСтр Из тЭлементы Цикл
   	тСтрЭлементы = тСтр.ПолучитьЭлементы();
   	СвернутьРекурсия(тСтрЭлементы);
		Если тЭлементы.Количество() > 1 Тогда
		Элементы.ДеревоСпецификации.Свернуть(тСтр.ПолучитьИдентификатор());		
		КонецЕсли; 
   	КонецЦикла; 
КонецПроцедуры

&НаКлиенте
Процедура Развернуть(Команда)
РазвернутьДерево();
КонецПроцедуры

&НаКлиенте
Процедура Свернуть(Команда)
СвернутьДерево();
КонецПроцедуры

&НаСервере
Процедура ОбходДереваДетально(ПереданноеДер) 
	Для Каждого Стр Из ПереданноеДер.Строки Цикл 
		Если Стр.ВернутьВКанбан Тогда
		СписокПоступления.Добавить(Стр.МПЗ,Строка(Стр.Количество));
		ИначеЕсли Стр.Списать Тогда	
		СписокСписания.Добавить(Стр.МПЗ,Строка(Стр.Количество));		
		КонецЕсли; 	 
			Если Стр.Строки.Количество() > 0 Тогда 
			ОбходДереваДетально(Стр);
			КонецЕсли; 
	КонецЦикла; 
КонецПроцедуры

&НаСервере
Процедура ПолучитьПараметры()
ДеревоЗнач = РеквизитФормыВЗначение("ДеревоСпецификации"); 
ОбходДереваДетально(ДеревоЗнач);
КонецПроцедуры

&НаКлиенте
Процедура Завершить(Команда)
ПолучитьПараметры();
ЭтаФорма.Закрыть(Новый Структура("СписокСписания,СписокПоступления",СписокСписания,СписокПоступления));
КонецПроцедуры

&НаКлиенте
Процедура ДеревоСпецификацииВернутьВКанбанПриИзменении(Элемент)
	Если Элементы.ДеревоСпецификации.ТекущиеДанные.Списать Тогда
	Элементы.ДеревоСпецификации.ТекущиеДанные.Списать = Ложь;	
	КонецЕсли;		
КонецПроцедуры

&НаКлиенте
Процедура ДеревоСпецификацииСписатьПриИзменении(Элемент)
	Если Элементы.ДеревоСпецификации.ТекущиеДанные.ВернутьВКанбан Тогда
	Элементы.ДеревоСпецификации.ТекущиеДанные.ВернутьВКанбан = Ложь;	
	КонецЕсли;
КонецПроцедуры
