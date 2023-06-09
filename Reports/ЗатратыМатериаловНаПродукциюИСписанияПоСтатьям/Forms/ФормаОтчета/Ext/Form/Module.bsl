﻿
&НаСервере
Процедура СформироватьПроизводственныеЗатраты()
ТабДок.Очистить(); 
ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблШапкаОбщая = Макет.ПолучитьОбласть("Шапка|Общая");
ОблШапкаПодразделение = Макет.ПолучитьОбласть("Шапка|Подразделение");
ОблШапкаВсегоПоСтроке = Макет.ПолучитьОбласть("Шапка|ВсегоПоСтроке");

ОблГруппаСтатейОбщая = Макет.ПолучитьОбласть("ГруппаСтатей|Общая");
ОблГруппаСтатейПодразделение = Макет.ПолучитьОбласть("ГруппаСтатей|Подразделение");
ОблГруппаСтатейВсегоПоСтроке = Макет.ПолучитьОбласть("ГруппаСтатей|ВсегоПоСтроке");

ОблПроизводствоОбщая = Макет.ПолучитьОбласть("Производство|Общая");
ОблПроизводствоПодразделение = Макет.ПолучитьОбласть("Производство|Подразделение");
ОблПроизводствоВсегоПоСтроке = Макет.ПолучитьОбласть("Производство|ВсегоПоСтроке");	

ОблШапкаОбщая.Параметры.ДатаНач = Формат(Отчет.Период.ДатаНачала,"ДФ=dd.MM.yyyy");
ОблШапкаОбщая.Параметры.ДатаКон = Формат(Отчет.Период.ДатаОкончания,"ДФ=dd.MM.yyyy");
ТабДок.Вывести(ОблШапкаОбщая);
	Для каждого Подразделение Из СписокПодразделений Цикл
	ОблШапкаПодразделение.Параметры.Подразделение = Подразделение.Значение;
	ТабДок.Присоединить(ОблШапкаПодразделение);
	КонецЦикла; 
ТабДок.Присоединить(ОблШапкаВсегоПоСтроке);

ОблГруппаСтатейОбщая.Параметры.ГруппаСтатей = "Списание материалов на изготовление продукции";
ТабДок.Вывести(ОблГруппаСтатейОбщая);
	Для каждого Подразделение Из СписокПодразделений Цикл
	ТабДок.Присоединить(ОблГруппаСтатейПодразделение);
	КонецЦикла;
ТабДок.Присоединить(ОблГруппаСтатейВсегоПоСтроке);
ТабДок.НачатьГруппуСтрок("По групп статей", Истина);

Запрос = Новый Запрос;

	Для каждого ГруппаМПЗ Из ВыбСписокГруппМПЗ Цикл
	КоличествоВсего = 0;
	СуммаВсего = 0;
	Запрос.Текст = 
		"ВЫБРАТЬ
		|	ПередачиВПроизводствоОстаткиИОбороты.МПЗ КАК МПЗ,
		|	ПередачиВПроизводствоОстаткиИОбороты.КоличествоРасход КАК КоличествоРасход,
		|	ПередачиВПроизводствоОстаткиИОбороты.Регистратор.Подразделение КАК Подразделение
		|ИЗ
		|	РегистрНакопления.ПередачиВПроизводство.ОстаткиИОбороты(&ДатаНач, &ДатаКон, Регистратор, , ) КАК ПередачиВПроизводствоОстаткиИОбороты
		|ГДЕ
		|	ПередачиВПроизводствоОстаткиИОбороты.Регистратор.Подразделение В(&СписокПодразделений)
		|	И ПередачиВПроизводствоОстаткиИОбороты.МПЗ В ИЕРАРХИИ(&ГруппаМПЗ)
		|ИТОГИ
		|	СУММА(КоличествоРасход)
		|ПО
		|	Подразделение,
		|	МПЗ";
	Запрос.УстановитьПараметр("ДатаНач", НачалоДня(Отчет.Период.ДатаНачала));
	Запрос.УстановитьПараметр("ДатаКон", КонецДня(Отчет.Период.ДатаОкончания));
	Запрос.УстановитьПараметр("СписокПодразделений", СписокПодразделений);
	Запрос.УстановитьПараметр("ГруппаМПЗ", ГруппаМПЗ.Значение);
	РезультатЗапроса = Запрос.Выполнить();
		Если РезультатЗапроса.Пустой() Тогда
		Продолжить;	
		КонецЕсли; 
	ВыборкаПодразделение = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	ОблПроизводствоОбщая.Параметры.ГруппаМПЗ = ГруппаМПЗ.Значение;
	ТабДок.Вывести(ОблПроизводствоОбщая);
		Для каждого Подразделение Из СписокПодразделений Цикл
		ВыборкаПодразделение.Сбросить();
			Если ВыборкаПодразделение.НайтиСледующий(Новый Структура("Подразделение",Подразделение.Значение)) Тогда
			Сумма = 0;
			ВыборкаМПЗ = ВыборкаПодразделение.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаМПЗ.Следующий() Цикл
				Сумма = Сумма + ВыборкаМПЗ.КоличествоРасход*ОбщийМодульВызовСервера.ПолучитьПоследнююЦену(ВыборкаМПЗ.МПЗ,ТекущаяДата());
				КонецЦикла; 	
			КоличествоРасход = ВыборкаПодразделение.КоличествоРасход;
			Иначе	
			КоличествоРасход = 0;
			Сумма = 0;
			КонецЕсли; 
		ОблПроизводствоПодразделение.Параметры.Количество = КоличествоРасход;
		ОблПроизводствоПодразделение.Параметры.Сумма = Сумма;
		ОблПроизводствоПодразделение.Параметры.СписокНастроек = Новый Структура("ГруппаМПЗ,Подразделение",ГруппаМПЗ.Значение,Подразделение.Значение);
		ТабДок.Присоединить(ОблПроизводствоПодразделение);
		КоличествоВсего = КоличествоВсего + КоличествоРасход;
		СуммаВсего = СуммаВсего + Сумма;
		Выборка = ТаблицаИтоговПроизводство.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
			Если Выборка.Количество() = 0 Тогда
            ТЧ = ТаблицаИтоговПроизводство.Добавить();
			ТЧ.Подразделение = Подразделение.Значение;
			ТЧ.Количество = ТЧ.Количество + КоличествоРасход;
			ТЧ.Сумма = ТЧ.Сумма + Сумма;
			Иначе
			Выборка[0].Количество = Выборка[0].Количество + КоличествоРасход;
			Выборка[0].Сумма = Выборка[0].Сумма + Сумма;
			КонецЕсли; 
		КонецЦикла;
	ОблПроизводствоВсегоПоСтроке.Параметры.КоличествоВсего = КоличествоВсего;
	ОблПроизводствоВсегоПоСтроке.Параметры.СуммаВсего = СуммаВсего; 
	ТабДок.Присоединить(ОблПроизводствоВсегоПоСтроке);
	КонецЦикла;
КонецПроцедуры

&НаСервере
Процедура СформироватьПоступленияИСписаниеПрочие()
ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблСтатьяСписанияОбщая = Макет.ПолучитьОбласть("СтатьяСписания|Общая");
ОблСтатьяСписанияПодразделение = Макет.ПолучитьОбласть("СтатьяСписания|Подразделение");
ОблСтатьяСписанияВсегоПоСтроке = Макет.ПолучитьОбласть("СтатьяСписания|ВсегоПоСтроке");

ОблГруппаСтатейИтогоОбщая = Макет.ПолучитьОбласть("ГруппаСтатейИтого|Общая");
ОблГруппаСтатейИтогоПодразделение = Макет.ПолучитьОбласть("ГруппаСтатейИтого|Подразделение");
ОблГруппаСтатейИтогоВсегоПоСтроке = Макет.ПолучитьОбласть("ГруппаСтатейИтого|ВсегоПоСтроке");

Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХраненияОбороты.Регистратор.Подразделение КАК Подразделение,
	|	МестаХраненияОбороты.Регистратор.Статья КАК Статья,
	|	МестаХраненияОбороты.МПЗ КАК МПЗ,
	|	МестаХраненияОбороты.КоличествоПриход КАК КоличествоПриход,
	|	МестаХраненияОбороты.КоличествоРасход КАК КоличествоРасход
	|ИЗ
	|	РегистрНакопления.МестаХранения.Обороты(&ДатаНач, &ДатаКон, Регистратор, ) КАК МестаХраненияОбороты
	|ГДЕ
	|	МестаХраненияОбороты.Регистратор.Подразделение В(&СписокПодразделений)
	|	И МестаХраненияОбороты.МПЗ В ИЕРАРХИИ(&ГруппаМПЗ)
	|	И (ТИПЗНАЧЕНИЯ(МестаХраненияОбороты.Регистратор) = ТИП(Документ.ПоступлениеМПЗПРочее)
	|			ИЛИ ТИПЗНАЧЕНИЯ(МестаХраненияОбороты.Регистратор) = ТИП(Документ.СписаниеМПЗПРочее)
	|			ИЛИ ТИПЗНАЧЕНИЯ(МестаХраненияОбороты.Регистратор) = ТИП(Документ.Разукомплектовка))
	|	И МестаХраненияОбороты.Регистратор.Статья В ИЕРАРХИИ(&СписокСтатей)
	|ИТОГИ
	|	СУММА(КоличествоПриход),
	|	СУММА(КоличествоРасход)
	|ПО
	|	Статья,
	|	Подразделение,
	|	МПЗ";
Запрос.УстановитьПараметр("ДатаНач", НачалоДня(Отчет.Период.ДатаНачала));
Запрос.УстановитьПараметр("ДатаКон", КонецДня(Отчет.Период.ДатаОкончания));
Запрос.УстановитьПараметр("СписокПодразделений", СписокПодразделений);
Запрос.УстановитьПараметр("ГруппаМПЗ", ВыбСписокГруппМПЗ);
Запрос.УстановитьПараметр("СписокСтатей", СписокСтатейПрочиеМатериалы);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаСтатья = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаСтатья.Следующий() Цикл
	КоличествоВсего = 0;
	СуммаВсего = 0;
	ОблСтатьяСписанияОбщая.Параметры.Статья = ВыборкаСтатья.Статья;
	ТабДок.Вывести(ОблСтатьяСписанияОбщая);
	ВыборкаПодразделение = ВыборкаСтатья.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Для каждого Подразделение Из СписокПодразделений Цикл
		Количество = 0;
		Сумма = 0;
		ВыборкаПодразделение.Сбросить();
			Если ВыборкаПодразделение.НайтиСледующий(Новый Структура("Подразделение",Подразделение.Значение)) Тогда
			ВыборкаМПЗ = ВыборкаПодразделение.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаМПЗ.Следующий() Цикл
				Количество = Количество + ВыборкаМПЗ.КоличествоРасход - ВыборкаМПЗ.КоличествоПриход;
				Цена = ОбщийМодульВызовСервера.ПолучитьПоследнююЦену(ВыборкаМПЗ.МПЗ,ТекущаяДата());	
				Сумма = Сумма + ВыборкаМПЗ.КоличествоРасход*Цена - ВыборкаМПЗ.КоличествоПриход*Цена;			
				КонецЦикла;
			КонецЕсли; 
		ОблСтатьяСписанияПодразделение.Параметры.Количество = Количество;
		ОблСтатьяСписанияПодразделение.Параметры.Сумма = Сумма;
		ОблСтатьяСписанияПодразделение.Параметры.СписокНастроек = Новый Структура("Статья,Подразделение",ВыборкаСтатья.Статья,Подразделение.Значение);
		ТабДок.Присоединить(ОблСтатьяСписанияПодразделение);
		КоличествоВсего = КоличествоВсего + Количество;
		СуммаВсего = СуммаВсего + Сумма;
		Выборка = ТаблицаИтоговПроизводство.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
		Выборка[0].Количество = Выборка[0].Количество + Количество;
		Выборка[0].Сумма = Выборка[0].Сумма + Сумма;
		КонецЦикла;
	ОблСтатьяСписанияВсегоПоСтроке.Параметры.КоличествоВсего = КоличествоВсего;
	ОблСтатьяСписанияВсегоПоСтроке.Параметры.СуммаВсего = СуммаВсего; 
	ТабДок.Присоединить(ОблСтатьяСписанияВсегоПоСтроке); 
	КонецЦикла;
ТабДок.ЗакончитьГруппуСтрок();
ОблГруппаСтатейИтогоОбщая.Параметры.ГруппаСтатей = "Списание материалов на изготовление продукции";
ТабДок.Вывести(ОблГруппаСтатейИтогоОбщая);
	Для каждого Подразделение Из СписокПодразделений Цикл
	Выборка = ТаблицаИтоговПроизводство.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
	ОблГруппаСтатейИтогоПодразделение.Параметры.КоличествоИтого = Выборка[0].Количество;
	ОблГруппаСтатейИтогоПодразделение.Параметры.СуммаИтого = Выборка[0].Сумма;
	ТабДок.Присоединить(ОблГруппаСтатейИтогоПодразделение);
	КонецЦикла;
ОблГруппаСтатейИтогоВсегоПоСтроке.Параметры.КоличествоИтогоВсего = ТаблицаИтоговПроизводство.Итог("Количество");
ОблГруппаСтатейИтогоВсегоПоСтроке.Параметры.СуммаИтогоВсего = ТаблицаИтоговПроизводство.Итог("Сумма"); 
ТабДок.Присоединить(ОблГруппаСтатейИтогоВсегоПоСтроке);
КонецПроцедуры

&НаСервере
Процедура СформироватьПоГруппеСтатей(ГруппаСтатей,СписокСтатей,ВывестиСоотношение)
ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

	Если Не ВывестиСоотношение Тогда
	ОблПустая = Макет.ПолучитьОбласть("Пустая");
	ТабДок.Вывести(ОблПустая);
	КонецЕсли; 

ОблГруппаСтатейОбщая = Макет.ПолучитьОбласть("ГруппаСтатей|Общая");
ОблГруппаСтатейПодразделение = Макет.ПолучитьОбласть("ГруппаСтатей|Подразделение");
ОблГруппаСтатейВсегоПоСтроке = Макет.ПолучитьОбласть("ГруппаСтатей|ВсегоПоСтроке");

ОблСтатьяСписанияОбщая = Макет.ПолучитьОбласть("СтатьяСписания|Общая");
ОблСтатьяСписанияПодразделение = Макет.ПолучитьОбласть("СтатьяСписания|Подразделение");
ОблСтатьяСписанияВсегоПоСтроке = Макет.ПолучитьОбласть("СтатьяСписания|ВсегоПоСтроке");

ОблГруппаСтатейИтогоОбщая = Макет.ПолучитьОбласть("ГруппаСтатейИтого|Общая");
ОблГруппаСтатейИтогоПодразделение = Макет.ПолучитьОбласть("ГруппаСтатейИтого|Подразделение");
ОблГруппаСтатейИтогоВсегоПоСтроке = Макет.ПолучитьОбласть("ГруппаСтатейИтого|ВсегоПоСтроке");

ОблСоотношениеОбщая = Макет.ПолучитьОбласть("Соотношение|Общая");
ОблСоотношениеПодразделение = Макет.ПолучитьОбласть("Соотношение|Подразделение");
ОблСоотношениеВсегоПоСтроке = Макет.ПолучитьОбласть("Соотношение|ВсегоПоСтроке");

ОблГруппаСтатейОбщая.Параметры.ГруппаСтатей = ГруппаСтатей;
ТабДок.Вывести(ОблГруппаСтатейОбщая);
	Для каждого Подразделение Из СписокПодразделений Цикл
	ТабДок.Присоединить(ОблГруппаСтатейПодразделение);
	КонецЦикла;
ТабДок.Присоединить(ОблГруппаСтатейВсегоПоСтроке);
ТабДок.НачатьГруппуСтрок("По групп статей", Истина);	

Запрос = Новый Запрос;

Запрос.Текст = 
	"ВЫБРАТЬ
	|	МестаХраненияОбороты.Регистратор.Подразделение КАК Подразделение,
	|	МестаХраненияОбороты.Регистратор.Статья КАК Статья,
	|	МестаХраненияОбороты.МПЗ КАК МПЗ,
	|	МестаХраненияОбороты.КоличествоПриход КАК КоличествоПриход,
	|	МестаХраненияОбороты.КоличествоРасход КАК КоличествоРасход
	|ИЗ
	|	РегистрНакопления.МестаХранения.Обороты(&ДатаНач, &ДатаКон, Регистратор, ) КАК МестаХраненияОбороты
	|ГДЕ
	|	МестаХраненияОбороты.Регистратор.Подразделение В(&СписокПодразделений)
	|	И МестаХраненияОбороты.МПЗ В ИЕРАРХИИ(&ГруппаМПЗ)
	|	И (ТИПЗНАЧЕНИЯ(МестаХраненияОбороты.Регистратор) = ТИП(Документ.ПоступлениеМПЗПРочее)
	|			ИЛИ ТИПЗНАЧЕНИЯ(МестаХраненияОбороты.Регистратор) = ТИП(Документ.СписаниеМПЗПРочее))
	|	И МестаХраненияОбороты.Регистратор.Статья В ИЕРАРХИИ(&СписокСтатей)
	|ИТОГИ
	|	СУММА(КоличествоПриход),
	|	СУММА(КоличествоРасход)
	|ПО
	|	Статья,
	|	Подразделение,
	|	МПЗ";
Запрос.УстановитьПараметр("ДатаНач", НачалоДня(Отчет.Период.ДатаНачала));
Запрос.УстановитьПараметр("ДатаКон", КонецДня(Отчет.Период.ДатаОкончания));
Запрос.УстановитьПараметр("СписокПодразделений", СписокПодразделений);
Запрос.УстановитьПараметр("ГруппаМПЗ", ВыбСписокГруппМПЗ);
Запрос.УстановитьПараметр("СписокСтатей", СписокСтатей);
РезультатЗапроса = Запрос.Выполнить();
ВыборкаСтатья = РезультатЗапроса.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
	Пока ВыборкаСтатья.Следующий() Цикл
	КоличествоВсего = 0;
	СуммаВсего = 0;
	ОблСтатьяСписанияОбщая.Параметры.Статья = ВыборкаСтатья.Статья;
	ТабДок.Вывести(ОблСтатьяСписанияОбщая);
	ВыборкаПодразделение = ВыборкаСтатья.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
		Для каждого Подразделение Из СписокПодразделений Цикл
		Количество = 0;
		Сумма = 0;
		ВыборкаПодразделение.Сбросить();
			Если ВыборкаПодразделение.НайтиСледующий(Новый Структура("Подразделение",Подразделение.Значение)) Тогда
			ВыборкаМПЗ = ВыборкаПодразделение.Выбрать(ОбходРезультатаЗапроса.ПоГруппировкам);
				Пока ВыборкаМПЗ.Следующий() Цикл
				Количество = Количество + ВыборкаМПЗ.КоличествоРасход - ВыборкаМПЗ.КоличествоПриход;
				Цена = ОбщийМодульВызовСервера.ПолучитьПоследнююЦену(ВыборкаМПЗ.МПЗ,ТекущаяДата());	
				Сумма = Сумма + ВыборкаМПЗ.КоличествоРасход*Цена - ВыборкаМПЗ.КоличествоПриход*Цена;			
				КонецЦикла;
			КонецЕсли; 
		ОблСтатьяСписанияПодразделение.Параметры.Количество = Количество;
		ОблСтатьяСписанияПодразделение.Параметры.Сумма = Сумма;
		ОблСтатьяСписанияПодразделение.Параметры.СписокНастроек = Новый Структура("Статья,Подразделение",ВыборкаСтатья.Статья,Подразделение.Значение);
		ТабДок.Присоединить(ОблСтатьяСписанияПодразделение);
		КоличествоВсего = КоличествоВсего + Количество;
		СуммаВсего = СуммаВсего + Сумма;
		Выборка = ТаблицаИтогов.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
			Если Выборка.Количество() = 0 Тогда
            ТЧ = ТаблицаИтогов.Добавить();
			ТЧ.Подразделение = Подразделение.Значение;
			ТЧ.Количество = ТЧ.Количество + Количество;
			ТЧ.Сумма = ТЧ.Сумма + Сумма;
			Иначе
			Выборка[0].Количество = Выборка[0].Количество + Количество;
			Выборка[0].Сумма = Выборка[0].Сумма + Сумма;
			КонецЕсли;
		Выборка = ТаблицаИтоговОбщая.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
			Если Выборка.Количество() = 0 Тогда
            ТЧ = ТаблицаИтоговОбщая.Добавить();
			ТЧ.Подразделение = Подразделение.Значение;
			ТЧ.Количество = ТЧ.Количество + Количество;
			ТЧ.Сумма = ТЧ.Сумма + Сумма;
			Иначе
			Выборка[0].Количество = Выборка[0].Количество + Количество;
			Выборка[0].Сумма = Выборка[0].Сумма + Сумма;
			КонецЕсли;
		КонецЦикла;
	ОблСтатьяСписанияВсегоПоСтроке.Параметры.КоличествоВсего = КоличествоВсего;
	ОблСтатьяСписанияВсегоПоСтроке.Параметры.СуммаВсего = СуммаВсего; 
	ТабДок.Присоединить(ОблСтатьяСписанияВсегоПоСтроке); 
	КонецЦикла;
ТабДок.ЗакончитьГруппуСтрок();
ОблГруппаСтатейИтогоОбщая.Параметры.ГруппаСтатей = ГруппаСтатей;
ТабДок.Вывести(ОблГруппаСтатейИтогоОбщая);
	Для каждого Подразделение Из СписокПодразделений Цикл
	Выборка = ТаблицаИтогов.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
		Если Выборка.Количество() > 0 Тогда
		ОблГруппаСтатейИтогоПодразделение.Параметры.КоличествоИтого = Выборка[0].Количество;
		ОблГруппаСтатейИтогоПодразделение.Параметры.СуммаИтого = Выборка[0].Сумма;
		Иначе
		ОблГруппаСтатейИтогоПодразделение.Параметры.КоличествоИтого = 0;
		ОблГруппаСтатейИтогоПодразделение.Параметры.СуммаИтого = 0;
		КонецЕсли;
	ТабДок.Присоединить(ОблГруппаСтатейИтогоПодразделение);
	КонецЦикла;
ОблГруппаСтатейИтогоВсегоПоСтроке.Параметры.КоличествоИтогоВсего = ТаблицаИтогов.Итог("Количество");
ОблГруппаСтатейИтогоВсегоПоСтроке.Параметры.СуммаИтогоВсего = ТаблицаИтогов.Итог("Сумма"); 
ТабДок.Присоединить(ОблГруппаСтатейИтогоВсегоПоСтроке);
	Если ВывестиСоотношение Тогда
	ОблСоотношениеОбщая.Параметры.ГруппаСтатей = ГруппаСтатей;
	ТабДок.Вывести(ОблСоотношениеОбщая);
		Для каждого Подразделение Из СписокПодразделений Цикл
		Выборка = ТаблицаИтогов.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
		ВыборкаП = ТаблицаИтоговПроизводство.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
			Если Выборка.Количество() > 0 Тогда
			ОблСоотношениеПодразделение.Параметры.ПроцентКоличество = ?(ВыборкаП[0].Количество <> 0,Окр(Выборка[0].Количество/ВыборкаП[0].Количество*100,2,1),0);
			ОблСоотношениеПодразделение.Параметры.ПроцентСумма = ?(ВыборкаП[0].Сумма <> 0,Окр(Выборка[0].Сумма/ВыборкаП[0].Сумма*100,2,1),0);
			Иначе
			ОблСоотношениеПодразделение.Параметры.ПроцентКоличество = 0;
			ОблСоотношениеПодразделение.Параметры.ПроцентСумма = 0;
			КонецЕсли;
		ТабДок.Присоединить(ОблСоотношениеПодразделение);
		КонецЦикла;
	ОблСоотношениеВсегоПоСтроке.Параметры.ПроцентКоличествоВсего = ?(ТаблицаИтоговПроизводство.Итог("Количество") <> 0,Окр(ТаблицаИтогов.Итог("Количество")/ТаблицаИтоговПроизводство.Итог("Количество")*100,2,1),0);
	ОблСоотношениеВсегоПоСтроке.Параметры.ПроцентСуммаВсего = ?(ТаблицаИтоговПроизводство.Итог("Сумма") <> 0,Окр(ТаблицаИтогов.Итог("Сумма")/ТаблицаИтоговПроизводство.Итог("Сумма")*100,2,1),0); 
	ТабДок.Присоединить(ОблСоотношениеВсегоПоСтроке);
	КонецЕсли;
КонецПроцедуры

&НаСервере
Процедура СформироватьИтоги()
ОбъектЗн = РеквизитФормыВЗначение("Отчет");
Макет = ОбъектЗн.ПолучитьМакет("Макет");

ОблКонецОбщая = Макет.ПолучитьОбласть("Конец|Общая");
ОблКонецПодразделение = Макет.ПолучитьОбласть("Конец|Подразделение");
ОблКонецВсегоПоСтроке = Макет.ПолучитьОбласть("Конец|ВсегоПоСтроке");

ТабДок.Вывести(ОблКонецОбщая);
	Для каждого Подразделение Из СписокПодразделений Цикл
	Выборка = ТаблицаИтоговОбщая.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
	ВыборкаП = ТаблицаИтоговПроизводство.НайтиСтроки(Новый Структура("Подразделение",Подразделение.Значение));
	ОблКонецПодразделение.Параметры.КоличествоИтого = Выборка[0].Количество;
	ОблКонецПодразделение.Параметры.СуммаИтого = Выборка[0].Сумма;
	ОблКонецПодразделение.Параметры.ПроцентКоличествоИтого = ?(ВыборкаП[0].Количество <> 0,Окр(Выборка[0].Количество/ВыборкаП[0].Количество*100,2,1),0);
	ОблКонецПодразделение.Параметры.ПроцентСуммаИтого = ?(ВыборкаП[0].Сумма <> 0,Окр(Выборка[0].Сумма/ВыборкаП[0].Сумма*100,2,1),0);
	ТабДок.Присоединить(ОблКонецПодразделение);
	КонецЦикла;
ОблКонецВсегоПоСтроке.Параметры.КоличествоИтогоВсего = ТаблицаИтоговОбщая.Итог("Количество");
ОблКонецВсегоПоСтроке.Параметры.СуммаИтогоВсего = ТаблицаИтоговОбщая.Итог("Сумма");
ОблКонецВсегоПоСтроке.Параметры.ПроцентКоличествоИтогоВсего = ?(ТаблицаИтоговПроизводство.Итог("Количество") <> 0,Окр(ТаблицаИтоговОбщая.Итог("Количество")/ТаблицаИтоговПроизводство.Итог("Количество")*100,2,1),0);
ОблКонецВсегоПоСтроке.Параметры.ПроцентСуммаИтогоВсего = ?(ТаблицаИтоговПроизводство.Итог("Сумма") <> 0,Окр(ТаблицаИтоговОбщая.Итог("Сумма")/ТаблицаИтоговПроизводство.Итог("Сумма")*100,2,1),0); 
ТабДок.Присоединить(ОблКонецВсегоПоСтроке);

ТабДок.ФиксацияСверху = 2;
ТабДок.ФиксацияСлева = 2;
КонецПроцедуры

&НаСервере
Процедура ПолучитьСписокГруппМПЗ()
ВыбСписокГруппМПЗ.Очистить();
	Если СписокГруппМПЗ.Количество() > 0  Тогда
	ВыбСписокГруппМПЗ = СписокГруппМПЗ.Скопировать();
	Иначе
	Мат = Справочники.Материалы.Выбрать(Справочники.Материалы.ПустаяСсылка());
		Пока Мат.Следующий() Цикл
			Если Мат.ЭтоГруппа Тогда
			ВыбСписокГруппМПЗ.Добавить(Мат.Ссылка);		
			КонецЕсли; 
		КонецЦикла; 	
	КонецЕсли;
КонецПроцедуры
 
&НаКлиенте
Процедура Сформировать(Команда)
	Если ЭтаФорма.ПроверитьЗаполнение() Тогда
	ТаблицаИтоговПроизводство.Очистить();
	ПолучитьСписокГруппМПЗ();
	Состояние("Обработка...",,"Обработка производственных затрат...",БиблиотекаКартинок.ДлительнаяОперация);
	СформироватьПроизводственныеЗатраты();
	Состояние("Обработка...",,"Обработка поступлений и списаний прочих...",БиблиотекаКартинок.ДлительнаяОперация);
	СформироватьПоступленияИСписаниеПрочие();
	Состояние("Обработка...",,"Обработка докуметов по спискам статей...",БиблиотекаКартинок.ДлительнаяОперация);
	ТаблицаИтогов.Очистить();
	ТаблицаИтоговОбщая.Очистить();
	СформироватьПоГруппеСтатей("ПрямыеПотери",СписокСтатейПрямыеПотери,Истина);
	ТаблицаИтогов.Очистить();
	СформироватьПоГруппеСтатей("Затраты на качество",СписокСтатейЗатратыНаКачество,Истина);
	ТаблицаИтогов.Очистить();
	СформироватьПоГруппеСтатей("Испытания",СписокСтатейИспытания,Истина);
	ТаблицаИтогов.Очистить();
	СформироватьПоГруппеСтатей("Стенды",СписокСтатейСтенды,Истина);
	ТаблицаИтогов.Очистить();
	СформироватьПоГруппеСтатей("Проектные затраты",СписокСтатейПроектныеЗатраты,Истина);
	ТаблицаИтогов.Очистить();
	СформироватьПоГруппеСтатей("Прямые потери поставщиков",СписокСтатейПрямыеПотериПоставщиков,Истина);
	ТаблицаИтогов.Очистить();
	СформироватьПоГруппеСтатей("Прочие потери",СписокСтатейПрочиеПотери,Истина);
	СформироватьИтоги();
	ТаблицаИтогов.Очистить();
	ТаблицаИтоговОбщая.Очистить();
	СформироватьПоГруппеСтатей("Прочие поступления, не влияющие на уменьшение потерь",СписокСтатейПрочиеПоступления,Ложь);
	КонецЕсли; 
КонецПроцедуры

&НаКлиенте
Процедура ТабДокОбработкаРасшифровки(Элемент, Расшифровка, СтандартнаяОбработка)
	Если Расшифровка.Свойство("ГруппаМПЗ") Тогда	
	СтандартнаяОбработка = Ложь;
	ИмяОтчета = "ОтчётПоРегиструПередачиВПроизводство";
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СформироватьПриОткрытии",Истина);
	ПараметрыФормы.Вставить("ПользовательскиеНастройки",ОбщийМодульВызовСервера.ЗаполнитьПользовательскиеНастройкиОтчетаСКД(ИмяОтчета,Отчет.Период.ДатаНачала,Отчет.Период.ДатаОкончания,Новый Структура("МПЗ,ДокументПодразделение",Расшифровка.ГруппаМПЗ,Расшифровка.Подразделение),"РасходПоМПЗ"));
	ПараметрыФормы.Вставить("КлючВарианта","РасходПоМПЗ"); 
	ОткрытьФорму("Отчет." + ИмяОтчета + ".Форма", ПараметрыФормы);
	ИначеЕсли Расшифровка.Свойство("Статья") Тогда	
	СтандартнаяОбработка = Ложь;
	ИмяОтчета = "ОтчётПоРегиструМестаХранения";
	ПараметрыФормы = Новый Структура;
	ПараметрыФормы.Вставить("СформироватьПриОткрытии",Истина);
	ПараметрыФормы.Вставить("ПользовательскиеНастройки",ОбщийМодульВызовСервера.ЗаполнитьПользовательскиеНастройкиОтчетаСКД(ИмяОтчета,Отчет.Период.ДатаНачала,Отчет.Период.ДатаОкончания,Новый Структура("ДокументСтатья,ДокументПодразделение,МПЗ",Расшифровка.Статья,Расшифровка.Подразделение,ВыбСписокГруппМПЗ),"ПоДокументамПрочим"));
	ПараметрыФормы.Вставить("КлючВарианта","ПоДокументамПрочим"); 
	ОткрытьФорму("Отчет." + ИмяОтчета + ".Форма", ПараметрыФормы);	
	КонецЕсли; 
КонецПроцедуры
