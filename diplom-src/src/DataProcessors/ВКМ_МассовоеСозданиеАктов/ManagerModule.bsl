#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область СлужебныеПроцедурыИФункции

Функция СозданиеСпискаНаСервере(Дата, СоздатьОбъект) Экспорт

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
	|	ДоговорыКонтрагентов.Владелец КАК Контрагент,
	|	ДоговорыКонтрагентов.Ссылка,
	|	ДоговорыКонтрагентов.Организация
	|ПОМЕСТИТЬ ВТ_ДанныеДог
	|ИЗ
	|	Справочник.ДоговорыКонтрагентов КАК ДоговорыКонтрагентов
	|ГДЕ
	|	&Дата МЕЖДУ ДоговорыКонтрагентов.ВКМ_ДатаНачала И ДоговорыКонтрагентов.ВКМ_ДатаОкончания
	|	И ДоговорыКонтрагентов.ВидДоговора = ЗНАЧЕНИЕ(Перечисление.ВидыДоговоровКонтрагентов.ВКМ_Абонент)
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	РеализацияТоваровУслуг.Ссылка,
	|	РеализацияТоваровУслуг.Контрагент,
	|	РеализацияТоваровУслуг.Договор
	|ПОМЕСТИТЬ ВТ_ДанныеРеализ
	|ИЗ
	|	Документ.РеализацияТоваровУслуг КАК РеализацияТоваровУслуг
	|ГДЕ
	|	РеализацияТоваровУслуг.Дата МЕЖДУ &ДатаНачало И &ДатаОкончание
	|	И РеализацияТоваровУслуг.ПометкаУдаления = ЛОЖЬ
	|;
	|
	|////////////////////////////////////////////////////////////////////////////////
	|ВЫБРАТЬ
	|	ВТ_ДанныеДог.Ссылка КАК Договор,
	|	ВТ_ДанныеРеализ.Ссылка КАК Реализация,
	|	ВТ_ДанныеДог.Организация,
	|	ВТ_ДанныеДог.Контрагент
	|ИЗ
	|	ВТ_ДанныеДог КАК ВТ_ДанныеДог
	|		ЛЕВОЕ СОЕДИНЕНИЕ ВТ_ДанныеРеализ КАК ВТ_ДанныеРеализ
	|		ПО ВТ_ДанныеДог.Ссылка = ВТ_ДанныеРеализ.Договор";

	Запрос.УстановитьПараметр("Дата", Дата);
	Запрос.УстановитьПараметр("ДатаНачало", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("ДатаОкончание", КонецМесяца(Дата));

	Результат = Запрос.Выполнить().Выбрать();

	МассивРеализаций = Новый Массив;

	Пока Результат.Следующий() Цикл
		РеализацииСтруктура = Новый Структура;
		Если СоздатьОбъект Тогда
			Если НЕ ЗначениеЗаполнено(Результат.Реализация) Тогда
				НоваяРеализация = СозданиеРеализации(Результат, КонецМесяца(Дата));
				РеализацииСтруктура.Вставить("Договор", Результат.Договор);
				РеализацииСтруктура.Вставить("Реализация", НоваяРеализация);
			Иначе
				РеализацииСтруктура.Вставить("Договор", Результат.Договор);
				РеализацииСтруктура.Вставить("Реализация", Результат.Реализация);
			КонецЕсли;
		Иначе
			РеализацииСтруктура.Вставить("Договор", Результат.Договор);
			РеализацииСтруктура.Вставить("Реализация", Результат.Реализация);
		КонецЕсли;

		МассивРеализаций.Добавить(РеализацииСтруктура);

	КонецЦикла;

	Возврат МассивРеализаций;

КонецФункции

Функция СозданиеРеализации(Результат, Дата)

	НовыйДок = Документы.РеализацияТоваровУслуг.СоздатьДокумент();
	НовыйДок.Дата = Дата;
	НовыйДок.Договор = Результат.Договор;
	НовыйДок.Контрагент = Результат.Контрагент;
	НовыйДок.Организация = Результат.Организация;
	НовыйДок.ВКМ_ВыполнитьАвтозаполнение();
	НовыйДок.Ответственный = Пользователи.ТекущийПользователь();

	НачатьТранзакцию();

	Если НовыйДок.ПроверитьЗаполнение() Тогда

		Попытка
			НовыйДок.Записать(РежимЗаписиДокумента.Проведение, РежимПроведенияДокумента.Неоперативный);
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ОбщегоНазначения.СообщитьПользователю("Проведение документа невозможно");
			ЗаписьЖурналаРегистрации("ОБРАБОТКА: Массовое создание актов отменено");
		КонецПопытки;

	Иначе
		ОбщегоНазначения.СообщитьПользователю(СтрШаблон(
			"Не удалось создать документ реализации по Договору: %1. Не все обязательные данные заполнены", Результат.Договор));
	КонецЕсли;

	Возврат НовыйДок.Ссылка;

КонецФункции

#КонецОбласти

#КонецЕсли