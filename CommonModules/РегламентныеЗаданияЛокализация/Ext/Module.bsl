﻿
#Область ПрограммныйИнтерфейс

// Определяет следующие свойств регламентных заданий:
//  - зависимость от функциональных опций.
//  - возможность выполнения в различных режимах работы программы.
//  - прочие параметры.
//
// см. РегламентныеЗаданияПереопределяемый.ПриОпредеПриОпределенииНастроекРегламентныхЗаданий()
//
Процедура ПриОпределенииНастроекРегламентныхЗаданий(Настройки) Экспорт
	
	//++ Локализация
	//++ НЕ ГОСИС
	
	//ИнтеграцияС1СДокументооборот
	ИнтеграцияС1СДокументооборот.ПриОпределенииНастроекРегламентныхЗаданий(Настройки);
	//Конец ИнтеграцияС1СДокументооборот
	
	
	
	Настройка = Настройки.Добавить();
	Настройка.РегламентноеЗадание = Метаданные.РегламентныеЗадания.ОбменССайтом;
	Настройка.РаботаетСВнешнимиРесурсами = Истина;
	
	Настройка = Настройки.Добавить();
	Настройка.РегламентноеЗадание = Метаданные.РегламентныеЗадания.ПроверкаКонтрагентов;
	Настройка.РаботаетСВнешнимиРесурсами = Истина;
	
	Настройка = Настройки.Добавить();
	Настройка.РегламентноеЗадание = Метаданные.РегламентныеЗадания.АрхивированиеЧековККМ;
	Настройка.РаботаетСВнешнимиРесурсами = Ложь;
	Настройка.ФункциональнаяОпция = Метаданные.ФункциональныеОпции.ИспользоватьРозничныеПродажи;
	
	Настройка = Настройки.Добавить();
	Настройка.РегламентноеЗадание = Метаданные.РегламентныеЗадания.УдалениеОтложенныхЧековККМ;
	Настройка.РаботаетСВнешнимиРесурсами = Ложь;
	Настройка.ФункциональнаяОпция = Метаданные.ФункциональныеОпции.ИспользоватьРозничныеПродажи;
	
	Настройка = Настройки.Добавить();
	Настройка.РегламентноеЗадание = Метаданные.РегламентныеЗадания.УдалениеЧековККМ;
	Настройка.РаботаетСВнешнимиРесурсами = Ложь;
	Настройка.ФункциональнаяОпция = Метаданные.ФункциональныеОпции.ИспользоватьРозничныеПродажи;

	//ЭлектронноеВзаимодействие
	ЭлектронноеВзаимодействие.ПриОпределенииНастроекРегламентныхЗаданий(Настройки);
	//Конец ЭлектронноеВзаимодействие
	
	//-- НЕ ГОСИС

	//++ НЕ ГОСИС
	ИнтеграцияГИСМ.ПриОпределенииНастроекРегламентныхЗаданий(Настройки);
	ИнтеграцияЕГАИС.ПриОпределенииНастроекРегламентныхЗаданий(Настройки);
	ИнтеграцияВЕТИС.ПриОпределенииНастроекРегламентныхЗаданий(Настройки);
	//-- НЕ ГОСИС
	//-- Локализация
	
	
КонецПроцедуры

#КонецОбласти
