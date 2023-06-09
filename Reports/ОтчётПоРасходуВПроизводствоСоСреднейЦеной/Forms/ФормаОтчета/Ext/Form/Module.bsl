﻿  
&НаСервере  
Функция ПолучитьЛинейкуКанбан(ВидКанбана)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	ЛинейкиВидыКанбанов.Ссылка КАК Ссылка
	|ИЗ
	|	Справочник.Линейки.ВидыКанбанов КАК ЛинейкиВидыКанбанов
	|ГДЕ
	|	ЛинейкиВидыКанбанов.Ссылка.ПометкаУдаления = ЛОЖЬ
	|	И ЛинейкиВидыКанбанов.ВидКанбана = &ВидКанбана";
Запрос.УстановитьПараметр("ВидКанбана", ВидКанбана);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныеЗаписи = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
	Возврат(ВыборкаДетальныеЗаписи.Ссылка);
	КонецЦикла;
Возврат(Неопределено);
КонецФункции
 
&НаСервере            
Функция ПолучитьЛинейкуПоПоследнемуВыпуску(Изделие)
Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ ПЕРВЫЕ 1
	|	ВыпускПродукцииКанбан.ДокументОснование.Линейка КАК Линейка
	|ИЗ
	|	Документ.ВыпускПродукцииКанбан КАК ВыпускПродукцииКанбан
	|ГДЕ
	|	ВыпускПродукцииКанбан.Изделие = &Изделие
	|
	|УПОРЯДОЧИТЬ ПО
	|	ВыпускПродукцииКанбан.Дата УБЫВ";
Запрос.УстановитьПараметр("Изделие",Изделие);		
РезультатЗапроса = Запрос.Выполнить();
ВыборкаДетальныхЗаписей = РезультатЗапроса.Выбрать();
	Пока ВыборкаДетальныхЗаписей.Следующий() Цикл
	Возврат(ВыборкаДетальныхЗаписей.Линейка.Родитель);
	КонецЦикла;
Возврат(Неопределено);
КонецФункции

&НаСервере
Процедура СформироватьНаСервере()
ТабДок.Очистить();
Запрос = Новый Запрос;
СписокДок = Новый СписокЗначений;
СписокВидовМПЗ = Новый СписокЗначений;

ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет"); 
ОблШапка = Макет.ПолучитьОбласть("Шапка");	
ОблИзделие = Макет.ПолучитьОбласть("Изделие");
ОблВидМПЗ = Макет.ПолучитьОбласть("ВидМПЗ");
ОблМПЗ = Макет.ПолучитьОбласть("МПЗ");	
ОблКонец = Макет.ПолучитьОбласть("Конец");	

ОблШапка.Параметры.ДатаНач = Формат(Период.ДатаНачала,"ДФ=dd.MM.yyyy");
ОблШапка.Параметры.ДатаКон = Формат(Период.ДатаОкончания,"ДФ=dd.MM.yyyy");
ТабДок.Вывести(ОблШапка);

	Если ВидыМПЗ = 0 Тогда
	СписокВидовМПЗ.Добавить(Перечисления.ВидыМПЗ.Материалы);	
	СписокВидовМПЗ.Добавить(Перечисления.ВидыМПЗ.Полуфабрикаты);
	ИначеЕсли ВидыМПЗ = 1 Тогда
	СписокВидовМПЗ.Добавить(Перечисления.ВидыМПЗ.Материалы);
	ИначеЕсли ВидыМПЗ = 2 Тогда	
	СписокВидовМПЗ.Добавить(Перечисления.ВидыМПЗ.Полуфабрикаты);	
	КонецЕсли;
		Если ВидОтчёта = 0 Тогда
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ВыпускПродукции.ДокументОснование.Изделие КАК Изделие,
			|	ВыпускПродукции.ДокументОснование.Количество КАК Количество,
			|	ВыпускПродукции.ДокументОснование КАК ДокументОснование
			|ИЗ
			|	Документ.ВыпускПродукции КАК ВыпускПродукции
			|ГДЕ
			|	ВыпускПродукции.НаСклад = ИСТИНА
			|	И ВыпускПродукции.Дата МЕЖДУ &ДатаНач И &ДатаКон";		
		Иначе	
		Запрос.Текст = 
			"ВЫБРАТЬ
			|	ВыпускПродукции.Изделие КАК Изделие,
			|	ВыпускПродукции.Количество КАК Количество,
			|	ВыпускПродукции.ДокументОснование.ДокументОснование КАК ДокументОснование
			|ИЗ
			|	Документ.ВыпускПродукцииКанбан КАК ВыпускПродукции
			|ГДЕ
			|	ВыпускПродукции.Дата МЕЖДУ &ДатаНач И &ДатаКон";		
		КонецЕсли;
			Если СписокПодразделений.Количество() > 0 Тогда
			Запрос.Текст = Запрос.Текст + " И ВыпускПродукции.Подразделение В ИЕРАРХИИ(&СписокПодразделений)";	
			Запрос.УстановитьПараметр("СписокПодразделений", СписокПодразделений);		
			КонецЕсли;
				Если СписокЛинеек.Количество() > 0 Тогда
				Запрос.Текст = Запрос.Текст + " И ВыпускПродукции.ДокументОснование.Линейка В ИЕРАРХИИ(&СписокЛинеек)";	
				Запрос.УстановитьПараметр("СписокЛинеек", СписокЛинеек);		
				КонецЕсли;
					Если СписокНоменклатуры.Количество() > 0 Тогда
					Запрос.Текст = Запрос.Текст + " И ВыпускПродукции.ДокументОснование.Изделие В ИЕРАРХИИ(&СписокНоменклатуры)";	
					Запрос.УстановитьПараметр("СписокНоменклатуры", СписокНоменклатуры);		
					КонецЕсли;
Запрос.Текст = Запрос.Текст + " УПОРЯДОЧИТЬ ПО
								|	ВыпускПродукции.ДокументОснование.Изделие.Товар.Наименование
								|ИТОГИ
								|	СУММА(Количество)
								|ПО
								|	Изделие";
Запрос.УстановитьПараметр("ДатаНач", Период.ДатаНачала);
Запрос.УстановитьПараметр("ДатаКон", Период.ДатаОкончания);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаИзделие = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаИзделие.Следующий() Цикл 
	СуммаРасходИтого = 0;
   	ЦенаЗаШтукуИтого = 0;
	ВыборкаДетальныеЗаписи = ВыборкаИзделие.Выбрать();
	СписокДок.Очистить();
		Пока ВыборкаДетальныеЗаписи.Следующий() Цикл
		СписокДок.Добавить(ВыборкаДетальныеЗаписи.ДокументОснование);
		КонецЦикла;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПередачиВПроизводствоОбороты.ВидМПЗ КАК ВидМПЗ,
		|	ПередачиВПроизводствоОбороты.МПЗ КАК МПЗ,
		|	ПередачиВПроизводствоОбороты.КоличествоПриход КАК КоличествоПриход
		|ИЗ
		|	РегистрНакопления.ПередачиВПроизводство.Обороты(, , Регистратор, ) КАК ПередачиВПроизводствоОбороты
		|ГДЕ
		|	ПередачиВПроизводствоОбороты.Документ В(&СписокДок)
		|	И ТИПЗНАЧЕНИЯ(ПередачиВПроизводствоОбороты.Регистратор) = ТИП(Документ.ПередачаВПроизводство)
		|   И ПередачиВПроизводствоОбороты.ВидМПЗ В (&СписокВидовМПЗ)";
	Запрос.Текст = Запрос.Текст + "  УПОРЯДОЧИТЬ ПО ПередачиВПроизводствоОбороты.ВидМПЗ, 
									|	ПередачиВПроизводствоОбороты.МПЗ.Наименование
									|ИТОГИ
									|	СУММА(КоличествоПриход)
									|ПО
									|	ВидМПЗ,
									|	МПЗ";
	Запрос.УстановитьПараметр("СписокДок", СписокДок);
	Запрос.УстановитьПараметр("СписокВидовМПЗ", СписокВидовМПЗ);
	РезультатЗапроса = Запрос.Выполнить();
	ВыборкаВидМПЗ = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Пока ВыборкаВидМПЗ.Следующий() Цикл
		ВыборкаМПЗ = ВыборкаВидМПЗ.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаМПЗ.Следующий() Цикл
			РЦС = РегистрыСведений.ЦеныСредние.ПолучитьПоследнее(Период.ДатаОкончания,Новый Структура("МПЗ",ВыборкаМПЗ.МПЗ)); 
			СуммаРасход = ВыборкаМПЗ.КоличествоПриход*РЦС.Цена;
			ЦенаЗаШтуку = СуммаРасход/ВыборкаИзделие.Количество;
			СуммаРасходИтого = СуммаРасходИтого + СуммаРасход;
		   	ЦенаЗаШтукуИтого = ЦенаЗаШтукуИтого + ЦенаЗаШтуку;
			КонецЦикла;
		КонецЦикла;
	ОблИзделие.Параметры.Наименование = СокрЛП(ВыборкаИзделие.Изделие.Наименование);
	ОблИзделие.Параметры.Изделие = ВыборкаИзделие.Изделие; 
	ОблИзделие.Параметры.ЕдиницаИзмерения = СокрЛП(ВыборкаИзделие.Изделие.ЕдиницаИзмерения.Наименование);
	ОблИзделие.Параметры.Количество = ВыборкаИзделие.Количество;
	ОблИзделие.Параметры.СуммаРасход = СуммаРасходИтого;
	ОблИзделие.Параметры.ЦенаЗаШтуку = ЦенаЗаШтукуИтого;  
		Если Не ВыборкаИзделие.Изделие.Канбан.Пустая() Тогда
		ОблИзделие.Параметры.ВидКанбана = СокрЛП(ВыборкаИзделие.Изделие.Канбан.Наименование);
		ЛинейкаКанбан = СписокДок[0].Значение.Линейка;
		ОблИзделие.Параметры.ГруппаЛинеек = СокрЛП(ЛинейкаКанбан.Родитель.Наименование);		
		ОблИзделие.Параметры.Подразделение = СокрЛП(ЛинейкаКанбан.Подразделение.Наименование);
		Иначе	
		ОблИзделие.Параметры.ВидКанбана = "";
		ОблИзделие.Параметры.Подразделение = СокрЛП(ВыборкаИзделие.Изделие.Линейка.Подразделение.Наименование);
		ОблИзделие.Параметры.ГруппаЛинеек = "";
		КонецЕсли;
			Если Не ВыборкаИзделие.Изделие.Товар.Пустая() Тогда
			ОблИзделие.Параметры.ГруппаЛинеек = СокрЛП(ВыборкаИзделие.Изделие.Линейка.Родитель.Наименование);		
			КонецЕсли;
	ТабДок.Вывести(ОблИзделие);
	ТабДок.НачатьГруппуСтрок("Изделие",Истина);	
	ВыборкаВидМПЗ.Сбросить();
		Пока ВыборкаВидМПЗ.Следующий() Цикл
		ОблВидМПЗ.Параметры.ВидМПЗ = ВыборкаВидМПЗ.ВидМПЗ;
		ТабДок.Вывести(ОблВидМПЗ);
		ТабДок.НачатьГруппуСтрок("ВидМПЗ",Истина);	
		ВыборкаМПЗ = ВыборкаВидМПЗ.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
			Пока ВыборкаМПЗ.Следующий() Цикл
			ОблМПЗ.Параметры.Наименование = СокрЛП(ВыборкаМПЗ.МПЗ.Наименование);
			ОблМПЗ.Параметры.МПЗ = ВыборкаМПЗ.МПЗ; 
			ОблМПЗ.Параметры.ЕдиницаИзмерения = СокрЛП(ВыборкаМПЗ.МПЗ.ЕдиницаИзмерения.Наименование);
			ОблМПЗ.Параметры.Количество = ВыборкаМПЗ.КоличествоПриход;
			ОблМПЗ.Параметры.Норма = ВыборкаМПЗ.КоличествоПриход/ВыборкаИзделие.Количество;
			РЦС = РегистрыСведений.ЦеныСредние.ПолучитьПоследнее(Период.ДатаОкончания,Новый Структура("МПЗ",ВыборкаМПЗ.МПЗ));
			ОблМПЗ.Параметры.Цена = РЦС.Цена; 
			ОблМПЗ.Параметры.СуммаРасход = ВыборкаМПЗ.КоличествоПриход*РЦС.Цена;
			ОблМПЗ.Параметры.ЦенаЗаШтуку = ОблМПЗ.Параметры.СуммаРасход/ВыборкаИзделие.Количество;
				Если ТипЗнч(ВыборкаМПЗ.МПЗ) = Тип("СправочникСсылка.Номенклатура") Тогда 
					Если Не ВыборкаМПЗ.МПЗ.Канбан.Пустая() Тогда
					ОблМПЗ.Параметры.ВидКанбана = СокрЛП(ВыборкаМПЗ.МПЗ.Канбан.Наименование);
					ГруппаЛинеек = ПолучитьЛинейкуПоПоследнемуВыпуску(ВыборкаМПЗ.МПЗ);
						Если ГруппаЛинеек <> Неопределено Тогда
						ОблМПЗ.Параметры.ГруппаЛинеек = СокрЛП(ГруппаЛинеек.Наименование);
						ОблМПЗ.Параметры.Подразделение = СокрЛП(ГруппаЛинеек.Подразделение.Наименование);
						Иначе	
						ОблМПЗ.Параметры.Подразделение = ""; 
						ОблМПЗ.Параметры.ГруппаЛинеек = "";						
						КонецЕсли;
					Иначе
 					ОблМПЗ.Параметры.ВидКанбана = "";
					ОблМПЗ.Параметры.Подразделение = ""; 
					ОблМПЗ.Параметры.ГруппаЛинеек = "";
					КонецЕсли;
				Иначе
 				ОблМПЗ.Параметры.ВидКанбана = "";
				ОблМПЗ.Параметры.Подразделение = "";
				ОблМПЗ.Параметры.ГруппаЛинеек = "";				
				КонецЕсли;
			ТабДок.Вывести(ОблМПЗ);
			КонецЦикла;
		ТабДок.ЗакончитьГруппуСтрок();
		КонецЦикла;
	ТабДок.ЗакончитьГруппуСтрок();
	КонецЦикла; 
ТабДок.Вывести(ОблКонец);
ТабДок.ФиксацияСверху = 2;
ТабДок.ФиксацияСлева = 1;
КонецПроцедуры

&НаКлиенте
Процедура Сформировать(Команда)
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
	СформироватьНаСервере();
	КонецЕсли;
КонецПроцедуры

&НаСервере
Функция НастройкиНаСервере()
Настройки = Новый Структура;
Настройки.Вставить("ВидОтчёта",ВидОтчёта);
Настройки.Вставить("ВидыМПЗ",ВидыМПЗ);
Настройки.Вставить("СписокЛинеек",СписокЛинеек);
Настройки.Вставить("СписокНоменклатуры",СписокНоменклатуры);
Настройки.Вставить("СписокПодразделений",СписокПодразделений);
Возврат(Новый Структура("КлючНазначенияИспользования,Настройки","ОтчётПоРасходуВПроизводствоСоСреднейЦеной",Настройки));
КонецФункции

&НаКлиенте
Процедура Настройки(Команда)
Результат = ОткрытьФормуМодально("ОбщаяФорма.НастройкиФорм",НастройкиНаСервере());
	Если Результат <> Неопределено Тогда	
	ВидОтчёта = Результат.ВидОтчёта;
	ВидыМПЗ = Результат.ВидыМПЗ;
	СписокЛинеек = Результат.СписокЛинеек;
	СписокНоменклатуры = Результат.СписокНоменклатуры;
	СписокПодразделений = Результат.СписокПодразделений;
	КонецЕсли;
КонецПроцедуры
