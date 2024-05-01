#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ОбработчикиСобытий

Процедура ОбработкаЗаполнения(ДанныеЗаполнения, ТекстЗаполнения, СтандартнаяОбработка)

	Ответственный = Пользователи.ТекущийПользователь();

	Если ТипЗнч(ДанныеЗаполнения) = Тип("ДокументСсылка.ЗаказПокупателя") Тогда
		ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения);
	КонецЕсли;

КонецПроцедуры

Процедура ПередЗаписью(Отказ, РежимЗаписи, РежимПроведения)

	Если ОбменДанными.Загрузка Тогда
		Возврат;
	КонецЕсли;

	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");

КонецПроцедуры

Процедура ОбработкаПроведения(Отказ, Режим)

	Движения.ОбработкаЗаказов.Записывать = Истина;
	Движения.ОстаткиТоваров.Записывать = Истина;

	Движение = Движения.ОбработкаЗаказов.Добавить();
	Движение.Период = Дата;
	Движение.Контрагент = Контрагент;
	Движение.Договор = Договор;
	Движение.Заказ = Основание;
	Движение.СуммаОтгрузки = СуммаДокумента;

	Для Каждого ТекСтрокаТовары Из Товары Цикл
		Движение = Движения.ОстаткиТоваров.Добавить();
		Движение.ВидДвижения = ВидДвиженияНакопления.Расход;
		Движение.Период = Дата;
		Движение.Контрагент = Контрагент;
		Движение.Номенклатура = ТекСтрокаТовары.Номенклатура;
		Движение.Сумма = ТекСтрокаТовары.Сумма;
		Движение.Количество = ТекСтрокаТовары.Количество;
	КонецЦикла;

КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Процедура ЗаполнитьНаОснованииЗаказаПокупателя(ДанныеЗаполнения)

	Запрос = Новый Запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |	ЗаказПокупателя.Организация КАК Организация,
				   |	ЗаказПокупателя.Контрагент КАК Контрагент,
				   |	ЗаказПокупателя.Договор КАК Договор,
				   |	ЗаказПокупателя.СуммаДокумента КАК СуммаДокумента,
				   |	ЗаказПокупателя.Товары.(
				   |		Ссылка КАК Ссылка,
				   |		НомерСтроки КАК НомерСтроки,
				   |		Номенклатура КАК Номенклатура,
				   |		Количество КАК Количество,
				   |		Цена КАК Цена,
				   |		Сумма КАК Сумма
				   |	) КАК Товары,
				   |	ЗаказПокупателя.Услуги.(
				   |		Ссылка КАК Ссылка,
				   |		НомерСтроки КАК НомерСтроки,
				   |		Номенклатура КАК Номенклатура,
				   |		Количество КАК Количество,
				   |		Цена КАК Цена,
				   |		Сумма КАК Сумма
				   |	) КАК Услуги
				   |ИЗ
				   |	Документ.ЗаказПокупателя КАК ЗаказПокупателя
				   |ГДЕ
				   |	ЗаказПокупателя.Ссылка = &Ссылка";

	Запрос.УстановитьПараметр("Ссылка", ДанныеЗаполнения);

	Выборка = Запрос.Выполнить().Выбрать();

	Если Не Выборка.Следующий() Тогда
		Возврат;
	КонецЕсли;

	ЗаполнитьЗначенияСвойств(ЭтотОбъект, Выборка);

	ТоварыОснования = Выборка.Товары.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Товары.Добавить(), ТоварыОснования);
	КонецЦикла;

	УслугиОснования = Выборка.Услуги.Выбрать();
	Пока ТоварыОснования.Следующий() Цикл
		ЗаполнитьЗначенияСвойств(Услуги.Добавить(), УслугиОснования);
	КонецЦикла;

	Основание = ДанныеЗаполнения;

КонецПроцедуры

//ВКМ Игнатова М.С. добавление автозаполнение таблицы услуги
Процедура ВКМ_ВыполнитьАвтозаполнение() Экспорт

	АбонентскаяПлата = Константы.ВКМ_НоменклатураАбонентскаяПлата.Получить();
	РаботыСпециалиста = Константы.ВКМ_НоменклатураРаботыСпециалиста.Получить();

	Если Не ЗначениеЗаполнено(АбонентскаяПлата) Тогда
		ОбщегоНазначения.СообщитьПользователю("Абонентская плата не заполнена");
		Возврат;
	КонецЕсли;
	Если Не ЗначениеЗаполнено(РаботыСпециалиста) Тогда
		ОбщегоНазначения.СообщитьПользователю("Работы специалиста не заполнены");
		Возврат;
	КонецЕсли;

	Услуги.Очистить();

	Если ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "ВКМ_АбонентскаяПлата") > 0 Тогда

		НоваяСтрока = Услуги.Добавить();
		НоваяСтрока.Номенклатура = АбонентскаяПлата;
		НоваяСтрока.Сумма = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Договор, "ВКМ_АбонентскаяПлата");

	КонецЕсли;

	Запрос = Новый запрос;
	Запрос.Текст = "ВЫБРАТЬ
				   |	ВКМ_ВыполненныеКлиентуРаботыОбороты.ВКМ_Договор КАК Договор,
				   |	СУММА(ЕСТЬNULL(ВКМ_ВыполненныеКлиентуРаботыОбороты.ВКМ_СуммаКОплатеОборот, 0)) КАК Сумма
				   |ИЗ
				   |	РегистрНакопления.ВКМ_ВыполненныеКлиентуРаботы.Обороты(&ДатаНачала, &ДатаОкончания,, ВКМ_Клиент = &Клиент
				   |	И ВКМ_Договор = &Договор) КАК ВКМ_ВыполненныеКлиентуРаботыОбороты
				   |СГРУППИРОВАТЬ ПО
				   |	ВКМ_ВыполненныеКлиентуРаботыОбороты.ВКМ_Договор";

	Запрос.УстановитьПараметр("ДатаНачала", НачалоМесяца(Дата));
	Запрос.УстановитьПараметр("ДатаОкончания", КонецМесяца(Дата));
	Запрос.УстановитьПараметр("Клиент", Контрагент);
	Запрос.УстановитьПараметр("Договор", Договор);

	Результат = Запрос.Выполнить().Выгрузить();
	Если Результат.Количество() <> 0 Тогда
		Если Результат[0].Сумма > 0 Тогда

			НоваяСтрока = Услуги.Добавить();
			НоваяСтрока.Номенклатура = РаботыСпециалиста;
			НоваяСтрока.Сумма = Результат[0].Сумма;

		КонецЕсли;
	КонецЕсли;
	
	СуммаДокумента = Товары.Итог("Сумма") + Услуги.Итог("Сумма");
КонецПроцедуры 
//ВКМ 

#КонецОбласти

#КонецЕсли