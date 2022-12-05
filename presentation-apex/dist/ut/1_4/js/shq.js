/*!
 Copyright (c) 2021, Oracle and/or its affiliates. All rights reserved.
 */
/**
 * @namespace apex.date
 * @since 21.2
 * @desc
 * <p>The apex.date namespace contains Oracle APEX functions related to date operations.</p>
 */

var apex = apex || {};
apex.date = {};

(function (date, locale, lang) {
    "use strict";

    /**
     * <p>Constants for the different date/time units used by apex.date functions.</p>
     *
     * @member {object} UNIT
     * @memberof apex.date
     * @property {string} MILLISECOND Constant to use for milliseconds
     * @property {string} SECOND Constant to use for seconds
     * @property {string} MINUTE Constant to use for minutes
     * @property {string} HOUR Constant to use for hours
     * @property {string} DAY Constant to use for days
     * @property {string} WEEK Constant to use for weeks
     * @property {string} MONTH Constant to use for months
     * @property {string} YEAR Constant to use for years
     *
     * @example <caption>apex.date.UNIT constant</caption>
     *
     * apex.date.UNIT = {
     *     MILLISECOND: "millisecond",
     *     SECOND: "second",
     *     MINUTE: "minute",
     *     HOUR: "hour",
     *     DAY: "day",
     *     WEEK: "week",
     *     MONTH: "month",
     *     YEAR: "year"
     * };
     *
     * @example <caption>Example usage</caption>
     *
     * apex.date.add( myDate, 2, apex.date.UNIT.DAY );
     * apex.date.add( myDate, 1, apex.date.UNIT.YEAR );
     * apex.date.subtract( myDate, 30, apex.date.UNIT.MINUTE );
     * apex.date.subtract( myDate, 6, apex.date.UNIT.HOUR );
     */
    date.UNIT = {
        MILLISECOND: "millisecond",
        SECOND: "second",
        MINUTE: "minute",
        HOUR: "hour",
        DAY: "day",
        WEEK: "week",
        MONTH: "month",
        YEAR: "year"
    };

    date.DEFAULT_DATE_FORMAT = "YYYY-MM-DD";

    // helper function to prepare & normalize dates for some comparing functions
    function prepareCompareDate(pDate, pUnit) {
        var localDate;

        if (pUnit === date.UNIT.YEAR) {
            localDate = new Date(pDate.getFullYear(), 0, 1, 0, 0, 0, 0);
        } else if (pUnit === date.UNIT.MONTH) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), 1, 0, 0, 0, 0);
        } else if (pUnit === date.UNIT.WEEK) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), pDate.getDate(), 0, 0, 0, 0);
        } else if (pUnit === date.UNIT.DAY) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), pDate.getDate(), 0, 0, 0, 0);
        } else if (pUnit === date.UNIT.HOUR) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), pDate.getDate(), pDate.getHours(), 0, 0, 0);
        } else if (pUnit === date.UNIT.MINUTE) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), pDate.getDate(), pDate.getHours(), pDate.getMinutes(), 0, 0);
        } else if (pUnit === date.UNIT.SECOND) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), pDate.getDate(), pDate.getHours(), pDate.getMinutes(), pDate.getSeconds(), 0);
        } else if (pUnit === date.UNIT.MILLISECOND) {
            localDate = new Date(pDate.getFullYear(), pDate.getMonth(), pDate.getDate(), pDate.getHours(), pDate.getMinutes(), pDate.getSeconds(), pDate.getMilliseconds());
        }

        return localDate;
    }

    /**
     * <p>Return true if a given object is a valid date object.</p>
     *
     * @function isValid
     * @memberof apex.date
     * @param {Date} pDate A date object
     * @return {boolean} is it a valid date
     *
     * @example <caption>Returns if a date object is valid.</caption>
     *
     * var isDateValid = apex.date.isValid( myDate );
     */
    date.isValid = function (pDate) {
        return pDate instanceof Date && !isNaN(pDate);
    };

    /**
     * <p>Return true if a given string can parse into a date object.
     * <em>Note: This could be browser specific dependent on the implementation of Date.parse.</em></p>
     * <p>Most browsers expect a string in ISO format (ISO 8601) and shorter versions of it, like "2021-06-15T14:30:00" or
     * "2021-06-15T14:30" or "2021-06-15"</p>
     *
     * @function isValidString
     * @memberof apex.date
     * @param {string} pDateString A date string
     * @return {boolean} is it a valid date
     *
     * @example <caption>Returns if a date string is valid.</caption>
     *
     * var isDateValid = apex.date.isValidString( "2021-06-29 15:30" );
     */
    date.isValidString = function (pDateString) {
        return !isNaN(Date.parse(pDateString));
    };

    /**
     * <p>Return the cloned instance of a given date object.
     * This is useful when you want to do actions on a date object without altering the original object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function clone
     * @memberof apex.date
     * @param {Date} pDate A date object
     * @return {Date} The cloned date object
     *
     * @example <caption>Returns the clone of a given date object.</caption>
     *
     * var myDate = new Date();
     * var clonedDate = apex.date.clone( myDate );
     */
    date.clone = function (pDate) {
        return new Date(pDate.getTime());
    };

    /**
     * <p>Add a certain amount of time to an existing date.
     * This function returns the modified date object as well as altering the original object.
     * If the given date object should not be manipulated use {@link apex.date.clone} before calling this function.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function add
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @param {number} pAmount The amount to add
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {Date} The modified date object
     *
     * @example <caption>Returns the modified date object.</caption>
     *
     * var myDate = new Date( "2021-06-20" );
     * myDate = apex.date.add( myDate, 2, apex.date.UNIT.DAY );
     * // myDate is now "2021-06-21"
     */
    date.add = function (pDate, pAmount, pUnit) {
        var localDate = pDate || new Date();

        function addMonths(pDate, pAmount) {
            var day = pDate.getDate();
            pDate.setMonth(pDate.getMonth() + pAmount);
            if (pDate.getDate() !== day) {
                pDate.setDate(0);
            }
            return pDate;
        }

        if (pUnit === date.UNIT.YEAR) {
            localDate.setFullYear(localDate.getFullYear() + pAmount);
        } else if (pUnit === date.UNIT.MONTH) {
            localDate = addMonths(localDate, pAmount);
        } else if (pUnit === date.UNIT.WEEK) {
            localDate.setDate(localDate.getDate() + 7 * pAmount);
        } else if (pUnit === date.UNIT.DAY) {
            localDate.setDate(localDate.getDate() + pAmount);
        } else if (pUnit === date.UNIT.HOUR) {
            localDate.setHours(localDate.getHours() + pAmount);
        } else if (pUnit === date.UNIT.MINUTE) {
            localDate.setTime(localDate.getTime() + 1000 * 60 * pAmount);
        } else if (pUnit === date.UNIT.SECOND) {
            localDate.setTime(localDate.getTime() + 1000 * pAmount);
        } else if (pUnit === date.UNIT.MILLISECOND) {
            localDate.setTime(localDate.getTime() + pAmount);
        }

        return localDate;
    };

    /**
     * <p>Subtract a certain amount of time of an existing date.
     * This function returns the modified date object as well as altering the original object.
     * If the given date object should not be manipulated use {@link apex.date.clone} before calling this function.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function subtract
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @param {number} pAmount The amount to subtract
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {Date} The modified date object
     *
     * @example <caption>Returns the modified date object.</caption>
     *
     * var myDate = new Date( "2021-06-20" )
     * myDate = apex.date.subtract( myDate, 2, apex.date.UNIT.DAY );
     * // myDate is now "2021-06-19"
     */
    date.subtract = function (pDate, pAmount, pUnit) {
        var localDate = pDate || new Date();

        localDate = date.add(localDate, -pAmount, pUnit);

        return localDate;
    };

    /**
     * <p>Return the ISO-8601 week number of the year of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function ISOWeek
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {number} The week number
     *
     * @example <caption>Returns the ISO-8601 week number.</caption>
     *
     * var weekNumber = apex.date.ISOWeek( myDate );
     */
    date.ISOWeek = function (pDate) {
        var localDate = date.clone(pDate || new Date()),
            dayn = (localDate.getDay() + 6) % 7,
            firstThursday;

        localDate.setDate(localDate.getDate() - dayn + 3);
        firstThursday = localDate.valueOf();
        localDate.setMonth(0, 1);

        if (localDate.getDay() !== 4) {
            localDate.setMonth(0, 1 + ((4 - localDate.getDay() + 7) % 7));
        }

        return 1 + Math.ceil((firstThursday - localDate) / 604800000);
    };

    /**
     * <p>Return the week number of a month of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function weekOfMonth
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {number} The week number
     *
     * @example <caption>Returns the week number of given month.</caption>
     *
     * var weekNumber = apex.date.weekOfMonth( myDate );
     */
    date.weekOfMonth = function (pDate) {
        var localDate = date.clone(pDate || new Date());

        localDate.setDate(localDate.getDate() - localDate.getDay() + 1);

        return Math.ceil(localDate.getDate() / 7);
    };

    /**
     * <p>Return the day count of a month of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function daysInMonth
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {number} The days count
     *
     * @example <caption>Returns the day count of given month.</caption>
     *
     * var dayCount = apex.date.daysInMonth( myDate );
     */
    date.daysInMonth = function (pDate) {
        var localDate = pDate || new Date();

        return new Date(localDate.getFullYear(), localDate.getMonth() + 1, 0).getDate();
    };

    /**
     * <p>Return the day number of week of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function dayOfWeek
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {number} The day number
     *
     * @example <caption>Returns the day number of given week.</caption>
     *
     * var weekDay = apex.date.dayOfWeek( myDate );
     */
    date.dayOfWeek = function (pDate) {
        var localDate = pDate || new Date();

        return localDate.getDay() === 0 ? 7 : localDate.getDay();
    };

    /**
     * <p>Return the day number of a year of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function getDayOfYear
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {number} The day number
     *
     * @example <caption>Returns the day number of given year.</caption>
     *
     * var dayNumber = apex.date.getDayOfYear( myDate );
     */
    date.getDayOfYear = function (pDate) {
        var localDate = pDate || new Date(),
            start = new Date(localDate.getFullYear(), 0, 0),
            diff = localDate - start,
            oneDay = 1000 * 60 * 60 * 24;

        return Math.floor(diff / oneDay);
    };

    /**
     * <p>Set the day number of a year of a given date object.
     * If the given date object should not be manipulated use {@link apex.date.clone} before calling this function.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function setDayOfYear
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @param {number} pDay The day number
     * @return {Date} The date object
     *
     * @example <caption>Returns the date object.</caption>
     *
     * var myDate = new Date();
     * apex.date.setDayOfYear( myDate, 126 );
     */
    date.setDayOfYear = function (pDate, pDay) {
        var localDate = pDate || new Date();
        localDate.setMonth(0, pDay);
    };

    /**
     * <p>Return the seconds past midnight of day of a given date object.</p>
     *
     * @function secondsPastMidnight
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {number} seconds past midnight
     *
     * @example <caption>Returns the seconds past midnight.</caption>
     *
     * var seconds = apex.date.secondsPastMidnight( myDate );
     */
    date.secondsPastMidnight = function (pDate) {
        var localDate = date.clone(pDate || new Date());

        return Math.round((date.clone(localDate) - localDate.setHours(0, 0, 0, 0)) / 1000, 0);
    };

    /**
     * <p>Return a new date object for the first day a month of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function firstOfMonth
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {Date} The first day as date
     *
     * @example <caption>Returns the first day of a given month as date object.</caption>
     *
     * var firstDayDate = apex.date.firstOfMonth( myDate );
     * // output: "2021-JUN-01" (as date object)
     */
    date.firstOfMonth = function (pDate) {
        var localDate = pDate || new Date();

        return new Date(localDate.getFullYear(), localDate.getMonth(), 1);
    };

    /**
     * <p>Return a new date object for the last day of a month of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function lastOfMonth
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {Date} The last day as date
     *
     * @example <caption>Returns the last day of a given month as date.</caption>
     *
     * var lastDayDate = apex.date.lastOfMonth( myDate );
     * // output: "2021-JUN-30" (as date object)
     */
    date.lastOfMonth = function (pDate) {
        var localDate = pDate || new Date();

        return new Date(localDate.getFullYear(), localDate.getMonth() + 1, 0);
    };

    /**
     * <p>Return the start date of a day of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function startOfDay
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {Date} The start date of a day
     *
     * @example <caption>Returns the start date of a given day.</caption>
     *
     * var dayStartDate = apex.date.startOfDay( myDate );
     * // output: "2021-JUN-29 24:00:00" (as date object)
     */
    date.startOfDay = function (pDate) {
        var localDate = pDate || new Date();

        return new Date(localDate.getFullYear(), localDate.getMonth(), localDate.getDate(), 0, 0, 0, 0);
    };

    /**
     * <p>Return the end date of a day of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function endOfDay
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {Date} The end date of a day
     *
     * @example <caption>Returns the end date of a given day.</caption>
     *
     * var dayEndDate = apex.date.endOfDay( myDate );
     * // output: "2021-JUN-29 23:59:59" (as date object)
     */
    date.endOfDay = function (pDate) {
        var localDate = pDate || new Date();

        return new Date(localDate.getFullYear(), localDate.getMonth(), localDate.getDate(), 23, 59, 59, 999);
    };

    /**
     * <p>Return the count of months between 2 date objects.</p>
     *
     * @function monthsBetween
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @return {number} The month count
     *
     * @example <caption>Returns the count of months between 2 dates.</caption>
     *
     * var months = apex.date.monthsBetween( myDate1, myDate2 );
     */
    date.monthsBetween = function (pDate1, pDate2) {
        var months;

        months = (pDate2.getFullYear() - pDate1.getFullYear()) * 12;
        months -= pDate1.getMonth();
        months += pDate2.getMonth();

        return Math.abs(months);
    };

    /**
     * <p>Return the minimum date of given date object arguments.
     * If <em>pDates</em> is not provided it uses the current date & time.</p>
     *
     * @function min
     * @memberof apex.date
     * @param {date} [pDates=[new Date()]] Multiple date objects as arguments
     * @return {Date} The min date object
     *
     * @example <caption>Returns the minimum (most distant future) of the given date.</caption>
     *
     * var minDate = apex.date.min( myDate1, myDate2, myDate3 );
     */
    date.min = function (pDates) {
        var dateArray = pDates || [new Date()];

        return new Date(Math.min.apply(null, dateArray));
    };

    /**
     * <p>Return the maximum date of given date object arguments.
     * If <em>pDates</em> is not provided it uses the current date & time.</p>
     *
     * @function max
     * @memberof apex.date
     * @param {date} [pDates=[new Date()]] Multiple date objects as arguments
     * @return {Date} The max date object
     *
     * @example <caption>Returns the maximum (most distant future) of the given date.</caption>
     *
     * var maxDate = apex.date.max( myDate1, myDate2, myDate3 );
     */
    date.max = function (pDates) {
        var dateArray = pDates || [new Date()];

        return new Date(Math.max.apply(null, dateArray));
    };

    /**
     * <p>Return true if the first date object is before the second date.
     * <em>pUnit</em> controls the precision of the comparison.</p>
     *
     * @function isBefore
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {boolean} is the date before
     *
     * @example <caption>Returns if a date object is before another.</caption>
     *
     * var isDateBefore = apex.date.isBefore( myDate1, myDate2, apex.date.UNIT.SECOND );
     */
    date.isBefore = function (pDate1, pDate2, pUnit) {
        var bool = false,
            unit = pUnit || date.UNIT.MILLISECOND,
            localDate1 = prepareCompareDate(pDate1, unit),
            localDate2 = prepareCompareDate(pDate2, unit);

        if (unit === date.UNIT.MILLISECOND) {
            bool = localDate1.getTime() < localDate2.getTime();
        } else {
            bool = localDate1 < date.add(date.subtract(localDate2, 1, unit), 1, date.UNIT.MILLISECOND);
        }

        return bool;
    };

    /**
     * <p>Return true if the first date object is after the second date.
     * <em>pUnit</em> controls the precision of the comparison.</p>
     *
     * @function isAfter
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {boolean} is the date after
     *
     * @example <caption>Returns if a date object is before another.</caption>
     *
     * var isDateAfter = apex.date.isAfter( myDate1, myDate2, apex.date.UNIT.SECOND );
     */
    date.isAfter = function (pDate1, pDate2, pUnit) {
        var bool = false,
            unit = pUnit || date.UNIT.MILLISECOND,
            localDate1 = prepareCompareDate(pDate1, unit),
            localDate2 = prepareCompareDate(pDate2, unit);

        if (unit === date.UNIT.MILLISECOND) {
            bool = localDate1.getTime() > localDate2.getTime();
        } else {
            bool = localDate1 > date.subtract(date.add(localDate2, 1, unit), 1, date.UNIT.MILLISECOND);
        }

        return bool;
    };

    /**
     * <p>Return true if the first date object is the same as the second date.
     * <em>pUnit</em> controls the precision of the comparison.</p>
     *
     * @function isSame
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {boolean} is the date same
     *
     * @example <caption>Returns if a date object is the same as another.</caption>
     *
     * var isDateSame = apex.date.isSame( myDate1, myDate2, apex.date.UNIT.SECOND );
     */
    date.isSame = function (pDate1, pDate2, pUnit) {
        var bool = false,
            unit = pUnit || date.UNIT.MILLISECOND,
            localDate1 = prepareCompareDate(pDate1, unit),
            localDate2 = prepareCompareDate(pDate2, unit);

        bool = localDate1.getTime() === localDate2.getTime();

        return bool;
    };

    /**
     * <p>Return true if the first date object is the same or before the second date.
     * <em>pUnit</em> controls the precision of the comparison.</p>
     *
     * @function isSameOrBefore
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {boolean} is the date same/before
     *
     * @example <caption>Returns if a date object is the same or before another.</caption>
     *
     * var isDateSameBefore = apex.date.isSameOrBefore( myDate1, myDate2, apex.date.UNIT.SECOND );
     */
    date.isSameOrBefore = function (pDate1, pDate2, pUnit) {
        var bool = false,
            unit = pUnit || date.UNIT.MILLISECOND,
            localDate1 = prepareCompareDate(pDate1, unit),
            localDate2 = prepareCompareDate(pDate2, unit);

        if (unit === date.UNIT.MILLISECOND) {
            bool = localDate1.getTime() <= localDate2.getTime();
        } else {
            bool = date.isSame(localDate1, localDate2) || localDate1 < date.add(date.subtract(localDate2, 1, unit), 1, date.UNIT.MILLISECOND);
        }

        return bool;
    };

    /**
     * <p>Return true if the first date object is the same or after the second date.
     * <em>pUnit</em> controls the precision of the comparison.</p>
     *
     * @function isSameOrAfter
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {boolean} is the date same/after
     *
     * @example <caption>Returns if a date object is the same or after another.</caption>
     *
     * var isDateSameAfter = apex.date.isSameOrAfter( myDate1, myDate2, apex.date.UNIT.SECOND );
     */
    date.isSameOrAfter = function (pDate1, pDate2, pUnit) {
        var bool = false,
            unit = pUnit || date.UNIT.MILLISECOND,
            localDate1 = prepareCompareDate(pDate1, unit),
            localDate2 = prepareCompareDate(pDate2, unit);

        if (unit === date.UNIT.MILLISECOND) {
            bool = localDate1.getTime() >= localDate2.getTime();
        } else {
            bool = date.isSame(localDate1, localDate2) || localDate1 > date.subtract(date.add(localDate2, 1, unit), 1, date.UNIT.MILLISECOND);
        }

        return bool;
    };

    /**
     * <p>Return true if the first date object is between the second date and the third date.
     * <em>pUnit</em> controls the precision of the comparison.</p>
     *
     * @function isBetween
     * @memberof apex.date
     * @param {Date} pDate1 A date object
     * @param {Date} pDate2 A date object
     * @param {Date} pDate3 A date object
     * @param {string} [pUnit=apex.date.UNIT.MILLISECOND] The unit to use - apex.date.UNIT constant
     * @return {boolean} is the date between
     *
     * @example <caption>Returns if a date object is between 2 another.</caption>
     *
     * var isDateBetween = apex.date.isBetween( myDate1, myDate2, myDate3, apex.date.UNIT.SECOND );
     */
    date.isBetween = function (pDate1, pDate2, pDate3, pUnit) {
        var bool = false,
            unit = pUnit || date.UNIT.MILLISECOND,
            localDate1 = prepareCompareDate(pDate1, unit),
            localDate2 = prepareCompareDate(pDate2, unit),
            localDate3 = prepareCompareDate(pDate3, unit);

        bool = localDate1 > localDate2 && localDate1 < localDate3;

        return bool;
    };

    /**
     * <p>Return true if a given date object is within a leap year.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function isLeapYear
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {boolean} is a leap year
     *
     * @example <caption>Returns if it's a leap year for a given date.</caption>
     *
     * var isLeapYear = apex.date.isLeapYear( myDate );
     */
    date.isLeapYear = function (pDate) {
        var localDate = pDate || new Date();

        return new Date(localDate.getFullYear(), 1, 29).getDate() === 29;
    };

    /**
     * <p>Return the ISO format string (ISO 8601) without timezone information of a given date object.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     *
     * @function toISOString
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @return {string} The formatted date string
     *
     * @example <caption>Returns date as ISO format string.</caption>
     *
     * var isoFormat = apex.date.toISOString( myDate );
     * // output: "2021-06-15:50:10"
     */
    date.toISOString = function (pDate) {
        var localDate = date.clone(pDate || new Date());

        date.add(localDate, localDate.getTimezoneOffset() * -1, date.UNIT.MINUTE);

        return localDate.toISOString().split(".")[0];
    };

    /**
     * <p>Return the relative date in words of a given date object
     * This is the client side counterpart of the PL/SQL function <em>APEX_UTIL.GET_SINCE</em>.
     * If <em>pDate</em> is not provided it uses the current date & time.</p>
     * @function since
     * @memberof apex.date
     * @param {string} [pDate=new Date()] A date object
     * @param {boolean} [pShort=false] Whether to return a short version of relative date
     * @return {string} The formatted date string
     *
     * @example <caption>Returns the relative date in words.</caption>
     *
     * var sinceString = apex.date.since( myDate );
     * // output: "2 days from now" or "30 minutes ago"
     *
     * var sinceString = apex.date.since( myDate, true );
     * // output: "In 1.1y" or "30m"
     */
    date.since = function (pDate, pShort) {
        pShort = pShort === undefined ? false : pShort ;
        var localDate = pDate || new Date(),
            now = new Date(),
            nowDateDifference = (now - localDate) / 1000,
            dateNowDifference = (localDate - now) / 1000,
            short = pShort,
            sinceText = "",
            formatMessage = lang.formatMessage,
            messages = {
                secondsAgo: short ? formatMessage("APEX.SINCE.SHORT.SECONDS_AGO", "#time#") : formatMessage("SINCE_SECONDS_AGO", "#time#"),
                minutesAgo: short ? formatMessage("APEX.SINCE.SHORT.MINUTES_AGO", "#time#") : formatMessage("SINCE_MINUTES_AGO", "#time#"),
                hoursAgo: short ? formatMessage("APEX.SINCE.SHORT.HOURS_AGO", "#time#") : formatMessage("SINCE_HOURS_AGO", "#time#"),
                daysAgo: short ? formatMessage("APEX.SINCE.SHORT.DAYS_AGO", "#time#") : formatMessage("SINCE_DAYS_AGO", "#time#"),
                weeksAgo: short ? formatMessage("APEX.SINCE.SHORT.WEEKS_AGO", "#time#") : formatMessage("SINCE_WEEKS_AGO", "#time#"),
                monthsAgo: short ? formatMessage("APEX.SINCE.SHORT.MONTHS_AGO", "#time#") : formatMessage("SINCE_MONTHS_AGO", "#time#"),
                yearsAgo: short ? formatMessage("APEX.SINCE.SHORT.YEARS_AGO", "#time#") : formatMessage("SINCE_YEARS_AGO", "#time#"),
                secondsFromNow: short ? formatMessage("APEX.SINCE.SHORT.SECONDS_FROM_NOW", "#time#") : formatMessage("SINCE_SECONDS_FROM_NOW", "#time#"),
                minutesFromNow: short ? formatMessage("APEX.SINCE.SHORT.MINUTES_FROM_NOW", "#time#") : formatMessage("SINCE_MINUTES_FROM_NOW", "#time#"),
                hoursFromNow: short ? formatMessage("APEX.SINCE.SHORT.HOURS_FROM_NOW", "#time#") : formatMessage("SINCE_HOURS_FROM_NOW", "#time#"),
                daysFromNow: short ? formatMessage("APEX.SINCE.SHORT.DAYS_FROM_NOW", "#time#") : formatMessage("SINCE_DAYS_FROM_NOW", "#time#"),
                weeksFromNow: short ? formatMessage("APEX.SINCE.SHORT.WEEKS_FROM_NOW", "#time#") : formatMessage("SINCE_WEEKS_FROM_NOW", "#time#"),
                monthsFromNow: short ? formatMessage("APEX.SINCE.SHORT.MONTHS_FROM_NOW", "#time#") : formatMessage("SINCE_MONTHS_FROM_NOW", "#time#"),
                yearsFromNow: short ? formatMessage("APEX.SINCE.SHORT.YEARS_FROM_NOW", "#time#") : formatMessage("SINCE_YEARS_FROM_NOW", "#time#"),
                now: formatMessage("SINCE_NOW")
            };

        // if a not valid date object is supplied, throw an error
        if (!date.isValid(localDate)) {
            throw new Error("Not a valid date");
        }

        // build since text for now, seconds, minutes, hours, days, months & years
        if (date.isSame(now, localDate, date.UNIT.SECOND)) {
            sinceText = messages.now;
        } else if (nowDateDifference > 0 && nowDateDifference < 60) {
            sinceText = messages.secondsAgo.replace("#time#", Math.round(nowDateDifference));
        } else if (dateNowDifference > 0 && dateNowDifference < 60) {
            sinceText = messages.secondsFromNow.replace("#time#", Math.round(dateNowDifference));
        } else if (nowDateDifference >= 60 && nowDateDifference < 60 * 60) {
            sinceText = messages.minutesAgo.replace("#time#", Math.round(nowDateDifference / 60));
        } else if (dateNowDifference >= 60 && dateNowDifference < 60 * 60) {
            sinceText = messages.minutesFromNow.replace("#time#", Math.round(dateNowDifference / 60));
        } else if (nowDateDifference >= 60 * 60 && nowDateDifference < 60 * 60 * 24 * 2) {
            sinceText = messages.hoursAgo.replace("#time#", Math.round(nowDateDifference / 60 / 60));
        } else if (dateNowDifference >= 60 * 60 && dateNowDifference < 60 * 60 * 24 * 2) {
            sinceText = messages.hoursFromNow.replace("#time#", Math.round(dateNowDifference / 60 / 60));
        } else if (nowDateDifference >= 60 * 60 * 24 * 2 && nowDateDifference < 60 * 60 * 24 * 14) {
            sinceText = messages.daysAgo.replace("#time#", Math.round(nowDateDifference / 60 / 60 / 24));
        } else if (dateNowDifference >= 60 * 60 * 24 * 2 && dateNowDifference < 60 * 60 * 24 * 14) {
            sinceText = messages.daysFromNow.replace("#time#", Math.round(dateNowDifference / 60 / 60 / 24));
        } else if (nowDateDifference >= 60 * 60 * 24 * 14 && nowDateDifference < 60 * 60 * 24 * 60) {
            sinceText = messages.weeksAgo.replace("#time#", Math.round(nowDateDifference / 60 / 60 / 24 / 7));
        } else if (dateNowDifference >= 60 * 60 * 24 * 14 && dateNowDifference < 60 * 60 * 24 * 60) {
            sinceText = messages.weeksFromNow.replace("#time#", Math.round(dateNowDifference / 60 / 60 / 24 / 7));
        } else if (nowDateDifference >= 60 * 60 * 24 * 60 && nowDateDifference < 60 * 60 * 24 * 365) {
            sinceText = messages.monthsAgo.replace("#time#", Math.round(date.monthsBetween(localDate, now)));
        } else if (dateNowDifference >= 60 * 60 * 24 * 60 && dateNowDifference < 60 * 60 * 24 * 365) {
            sinceText = messages.monthsFromNow.replace("#time#", Math.round(date.monthsBetween(now, localDate)));
        } else if (nowDateDifference >= 60 * 60 * 24 * 365) {
            sinceText = messages.yearsAgo.replace("#time#", (date.monthsBetween(localDate, now) / 12).toFixed(1));
        } else if (dateNowDifference >= 60 * 60 * 24 * 365) {
            sinceText = messages.yearsFromNow.replace("#time#", (date.monthsBetween(now, localDate) / 12).toFixed(1));
        }

        return sinceText;
    };

    /**
     * <p>Return the formatted string of a date with a given (Oracle compatible) format mask.
     * If <em>pDate</em> is not provided it uses the current date & time.
     * It uses the default date format mask & locale defined in the application globalization settings.</p>
     *
     * <p>Currently not supported Oracle specific formats are:
     * SYEAR,SYYYY,IYYY,YEAR,IYY,SCC,TZD,TZH,TZM,TZR,AD,BC,CC,EE,FF,FX,IY,RM,TS,E,I,J,Q,X"</p>
     *
     * @function format
     * @memberof apex.date
     * @param {Date} [pDate=new Date()] A date object
     * @param {string} [pFormat=apex.date.DEFAULT_DATE_FORMAT] The format mask
     * @param {string} [pLocale=apex.locale.getLanguage()] The locale
     * @return {string} The formatted date string
     *
     * @example <caption>Returns the formatted date string.</caption>
     *
     * var dateString = apex.date.format( myDate, "YYYY-MM-DD HH24:MI" );
     * // output: "2021-06-29 15:30"
     *
     * var dateString = apex.date.format( myDate, "Day, DD Month YYYY" );
     * // output: "Wednesday, 29 June 2021"
     *
     * var dateString = apex.date.format( myDate, "Day, DD Month YYYY", "de" );
     * // output: "Mittwoch, 29 Juni 2021"
     */
    date.format = function (pDate, pFormat, pLocale) {
        var localDate = pDate || new Date(),
            locales = pLocale || locale.getLanguage() || "default",
            formatMask = pFormat || date.DEFAULT_DATE_FORMAT,
            formatMaskSearch = formatMask.toUpperCase(),
            formatTokenString = "MONTH|SSSSS|HH12|HH24|RRRR|YYYY|DAY|DDD|MON|AM|DD|DL|DS|DY|FM|HH|IW|MI|MM|PM|RR|SS|WW|YY|D|W",
            notSupportedTokenString = "SYEAR|SYYYY|IYYY|YEAR|IYY|SCC|TZD|TZH|TZM|TZR|AD|BC|CC|EE|FF|FX|IY|RM|TS|E|I|J|Q|X",
            formatTokens = [],
            formatToken = "",
            notSupportedTokens = [],
            notSupportedToken = "",
            formatMaskPart,
            findings = [],
            finding,
            formattedString,
            i;

        function _isSubstringEnquoted(pString, pSubstring) {
            var string = pString.toUpperCase(),
                subString = pSubstring.toUpperCase(),
                subStringIndex = string.indexOf(subString);

            return string.substr(0, subStringIndex).includes('"') && string.substr(subStringIndex + 1, string.length).includes('"');
        }

        function _isUpperCase(pString ) {
            pString = pString === undefined ? "" : pString;
            return pString === pString.toUpperCase();
        }

        function _isLowerCase(pString ) {
            pString = pString === undefined ? "" : pString;
            return pString === pString.toLowerCase();
        }

        function _isInitCase(pString ) {
            pString = pString === undefined ? "" : pString;
            return pString.charAt(0) === pString.charAt(0).toUpperCase() && pString.substr(1) === pString.substr(1).toLowerCase();
        }

        function _toInitCase(pString ) {
            pString = pString === undefined ? "" : pString;
            return pString.charAt(0).toUpperCase() + pString.substr(1).toLowerCase();
        }

        function _getDatePart(pDate, pPartFormat) {
            var datePart = {
                YYYY: function (d) {
                    return d.getFullYear();
                },
                YY: function (d) {
                    return d.getFullYear().toString().substr(2, 4);
                },
                RRRR: function (d) {
                    return d.getFullYear();
                },
                RR: function (d) {
                    return d.getFullYear().toString().substr(2, 4);
                },
                MONTH: function (d) {
                    return d.toLocaleString(locales, { month: "long" }).toUpperCase();
                },
                MON: function (d) {
                    return d.toLocaleString(locales, { month: "short" }).toUpperCase();
                },
                MM: function (d) {
                    return ("0" + (d.getMonth() + 1)).slice(-2);
                },
                IW: function (d) {
                    return ("0" + date.ISOWeek(d)).slice(-2);
                },
                WW: function (d) {
                    return ("0" + date.ISOWeek(d)).slice(-2);
                },
                W: function (d) {
                    return date.weekOfMonth(d);
                },
                DAY: function (d) {
                    return d.toLocaleString(locales, { weekday: "long" }).toUpperCase();
                },
                DDD: function (d) {
                    return ("0" + date.dayOfYear(d)).slice(-3);
                },
                DD: function (d) {
                    return ("0" + d.toLocaleString("default", { day: "numeric" })).slice(-2);
                },
                DY: function (d) {
                    return d.toLocaleString(locales, { weekday: "short" }).toUpperCase();
                },
                DL: function (d) {
                    return d.toLocaleString(locales, { weekday: "long", day: "2-digit", month: "long", year: "numeric" });
                },
                DS: function (d) {
                    return d.toLocaleString(locales, { day: "2-digit", month: "2-digit", year: "numeric" });
                },
                D: function (d) {
                    return d.getDay() + 1;
                },
                HH24: function (d) {
                    return d.toLocaleString(locales, { hour: "2-digit", hour12: false }).substr(0, 2);
                },
                HH12: function (d) {
                    return d.toLocaleString(locales, { hour: "2-digit", hour12: true }).substr(0, 2);
                },
                HH: function (d) {
                    return d.toLocaleString(locales, { hour: "2-digit", hour12: true }).substr(0, 2);
                },
                AM: function (d) {
                    return d.toLocaleString("default", { hour: "2-digit", hour12: true }).substr(3, 2);
                },
                PM: function (d) {
                    return d.toLocaleString("default", { hour: "2-digit", hour12: true }).substr(3, 2);
                },
                MI: function (d) {
                    return ("0" + d.toLocaleString("default", { minute: "numeric" })).slice(-2);
                },
                SSSSS: function (d) {
                    return date.secondsPastMidnight(d);
                },
                SS: function (d) {
                    return ("0" + d.toLocaleString("default", { second: "numeric" })).slice(-2);
                }
            };

            return datePart[pPartFormat](pDate);
        }

        // if a not valid date object is supplied, throw an error
        if (!date.isValid(localDate)) {
            throw new Error("Not a valid date");
        }

        // special handling of SINCE format mask
        if (formatMaskSearch === "SINCE") {
            return date.since(localDate);
        }

        // find token matches in supplied format mask which we can use to translate into date parts
        formatTokens = formatTokenString.split("|");

        for (i = 0; i < formatTokens.length; i++) {
            formatToken = formatTokens[i];

            // check for format mask tokens, but not the ones within quotes
            if (formatMaskSearch.includes(formatToken)) {
                if (!_isSubstringEnquoted(formatMask, formatToken)) {
                    findings.push({
                        id: i,
                        name: formatToken,
                        textCase:
                            formatToken === "DS" || formatToken === "DL"
                                ? "original"
                                : _isUpperCase(formatMask.substr(formatMask.toUpperCase().indexOf(formatToken), formatToken.length))
                                    ? "upper"
                                    : _isLowerCase(formatMask.substr(formatMask.toUpperCase().indexOf(formatToken), formatToken.length))
                                        ? "lower"
                                        : _isInitCase(formatMask.substr(formatMask.toUpperCase().indexOf(formatToken), formatToken.length))
                                            ? "init"
                                            : "upper"
                    });
                    formatMask = formatMask.replace(new RegExp(formatToken, "ig"), "~~" + i + "~~");
                }
                formatMaskSearch = formatMaskSearch.replace(new RegExp(formatToken, "g"), "");
            }
        }

        // lookup not yet supported tokens in remaining format mask, if found and not within quotes throw an error
        notSupportedTokens = notSupportedTokenString.split("|");

        for (i = 0; i < notSupportedTokens.length; i++) {
            notSupportedToken = notSupportedTokens[i];

            if (formatMaskSearch.includes(notSupportedToken) && !_isSubstringEnquoted(formatMaskSearch, notSupportedToken)) {
                throw new Error("Format not supported: " + notSupportedToken);
            }
        }

        // now we are building the final formatted output from our findings
        formattedString = formatMask;

        for (i = 0; i < findings.length; i++) {
            finding = findings[i];

            formatMaskPart = _getDatePart(localDate, finding.name).toString();

            switch (finding.textCase) {
                case "upper":
                    formatMaskPart = formatMaskPart.toUpperCase();
                    break;
                case "lower":
                    formatMaskPart = formatMaskPart.toLowerCase();
                    break;
                case "init":
                    formatMaskPart = _toInitCase(formatMaskPart);
                    break;
            }

            formattedString = formattedString.replace(new RegExp("~~" + finding.id + "~~", "g"), formatMaskPart);
        }

        // remove quotes special escaped parts, like "T" in YYYY-MM-DD"T"HH:MM:SS
        if (formattedString.includes('"')) {
            formattedString = formattedString.replace(new RegExp('"', "g"), "");
        }

        return formattedString;
    };

    /**
     * <p>Return the parsed date object of a given date string and a (Oracle compatible) format mask.
     * It uses the default date format mask defined in the application globalization settings.</p>
     *
     * <p>Currently not supported Oracle specific formats are:
     * MONTH,SSSSS,SYEAR,SYYYY,IYYY,YEAR,DAY,IYY,SCC,TZD,TZH,TZM,TZR,AD,BC,CC,DL,DS,DY,EE,FF,FX,IW,IY,RM,TS,WW,E,I,J,Q,W,X</p>
     *
     * @function parse
     * @memberof apex.date
     * @param {string} pDateString A formatted date string
     * @param {string} [pFormat=apex.date.DEFAULT_DATE_FORMAT] The format mask
     * @return {Date} The date object
     *
     * @example <caption>Returns the parsed date object.</caption>
     *
     * var date = apex.date.parse( "2021-06-29 15:30", "YYYY-MM-DD HH24:MI" );
     * var date = apex.date.parse( "2021-JUN-29 08:30 am", "YYYY-MON-DD HH12:MI AM" );
     */
    date.parse = function (pDateString, pFormat) {
        var localDate = new Date(),
            dateString = pDateString || "",
            formatMask = pFormat || date.DEFAULT_DATE_FORMAT,
            formatMaskSearch = formatMask.toUpperCase(),
            formatTokenString = "HH12|HH24|RRRR|YYYY|DDD|MON|AM|DD|FM|HH|MI|MM|PM|RR|SS|YY|D",
            notSupportedTokenString = "MONTH|SSSSS|SYEAR|SYYYY|IYYY|YEAR|DAY|IYY|SCC|TZD|TZH|TZM|TZR|AD|BC|CC|DL|DS|DY|EE|FF|FX|IW|IY|RM|TS|WW|E|I|J|Q|W|X",
            formatTokens = [],
            formatToken = "",
            notSupportedTokens = [],
            notSupportedToken = "",
            findings = [],
            finding,
            dateStringPart,
            correctFollowFindings = false,
            findingStart = 0,
            findingEnd = 0,
            correctStartIndex = 0,
            i;

        function _getMonthNumber(pMonth) {
            return new Date(Date.parse(pMonth + " 1, 2021")).getMonth() + 1;
        }

        function _setDayOfWeek(pDate, pDay) {
            var currentDay = pDate.getDay() + 1,
                distance = pDay - currentDay;
            pDate.setDate(pDate.getDate() + distance);
        }

        function _setDatePart(pDate, pPartValue, pPartFormat) {
            var setDatePart = {
                YYYY: function (d, v) {
                    d.setFullYear(v);
                },
                YY: function (d, v) {
                    d.setFullYear(d.getFullYear().toString().substr(0, 2) + v);
                },
                RRRR: function (d, v) {
                    d.setFullYear(v);
                },
                RR: function (d, v) {
                    d.setFullYear(d.getFullYear().toString().substr(0, 2) + v);
                },
                MON: function (d, v) {
                    d.setMonth(_getMonthNumber(v) - 1);
                },
                MM: function (d, v) {
                    d.setMonth(parseInt(v, 10) - 1);
                },
                DDD: function (d, v) {
                    date.setDayOfYear(d, parseInt(v, 10));
                },
                DD: function (d, v) {
                    d.setDate(parseInt(v, 10));
                },
                D: function (d, v) {
                    _setDayOfWeek(d, parseInt(v, 10));
                },
                HH24: function (d, v) {
                    d.setHours(parseInt(v, 10));
                },
                HH12: function (d, v) {
                    d.setHours(parseInt(v, 10));
                },
                HH: function (d, v) {
                    d.setHours(parseInt(v, 10));
                },
                AM: function (d, v) {
                    if (v.toUpperCase() === "AM" && d.getHours() > 12) {
                        d.setHours(d.getHours() - 12);
                    } else if (v.toUpperCase() === "PM" && d.getHours() < 12) {
                        d.setHours(d.getHours() + 12);
                    }
                },
                PM: function (d, v) {
                    if (v.toUpperCase() === "AM" && d.getHours() > 12) {
                        d.setHours(d.getHours() - 12);
                    } else if (v.toUpperCase() === "PM" && d.getHours() < 12) {
                        d.setHours(d.getHours() + 12);
                    }
                },
                MI: function (d, v) {
                    d.setMinutes(parseInt(v, 10));
                },
                SS: function (d, v) {
                    d.setSeconds(parseInt(v, 10));
                }
            };

            setDatePart[pPartFormat](pDate, pPartValue);
        }

        // exit when no date string is provided
        if (!dateString) {
            return;
        }

        // reset hour, minutes, seconds, milliseconds
        localDate.setHours(0, 0, 0, 0);

        // first check if string is already parsable as a date, only when no format mask is supplied
        if (!pFormat && date.isValidString(dateString)) {
            localDate = new Date(dateString);
            // now we have to parse it by our own
        } else {
            // find token matches in supplied format mask which we can use to translate into date parts
            formatTokens = formatTokenString.split("|");

            for (i = 0; i < formatTokens.length; i++) {
                formatToken = formatTokens[i];

                if (formatMaskSearch.includes(formatToken)) {
                    findingStart = formatMask.toUpperCase().indexOf(formatToken);
                    findingEnd = formatMask.toUpperCase().indexOf(formatToken) + formatToken.length;

                    // correct start & end position if a format mask part could be longer than the real data, e.g. HH24 --> 13
                    if (formatToken === "HH24" || formatToken === "HH12") {
                        findingEnd = findingEnd - 2;
                        correctStartIndex = findingStart;
                        correctFollowFindings = true;
                    }

                    findings.push({
                        id: i,
                        name: formatToken,
                        start: findingStart,
                        end: findingEnd
                    });

                    formatMaskSearch = formatMaskSearch.replace(formatToken, new Array(formatToken.length + 1).join(i));
                }
            }

            // correct start & end position of following findings, if e.g. HH24 or HH12 was used
            if (correctFollowFindings) {
                findings
                    .filter(function (elem) {
                        return elem.start > correctStartIndex;
                    })
                    .forEach(function (item) {
                        item.start = item.start - 2;
                        item.end = item.end - 2;
                    });
            }

            // lookup not yet supported tokens in remaining format mask, if found thow an error
            notSupportedTokens = notSupportedTokenString.split("|");

            for (i = 0; i < notSupportedTokens.length; i++) {
                notSupportedToken = notSupportedTokens[i];

                if (formatMaskSearch.includes(notSupportedToken)) {
                    throw new Error("Format not supported: " + notSupportedToken);
                }
            }

            // now we are building the final formatted output from our findings
            for (i = 0; i < findings.length; i++) {
                finding = findings[i];

                dateStringPart = dateString.substring(finding.start, finding.end);

                _setDatePart(localDate, dateStringPart, finding.name);
            }
        }

        // if a not valid date object is generated, throw an error
        if (!date.isValid(localDate)) {
            throw new Error("Date Parsing Error");
        }

        return localDate;
    };

    //
    // Wrappers for functions from other namespaces, which could be date related
    // Just for convenience, already documented
    //

    date.getAbbrevMonthNames = function () {
        return locale.getAbbrevMonthNames();
    };

    date.getAbbrevDayNames = function () {
        return locale.getAbbrevDayNames();
    };
})(apex.date, apex.locale, apex.lang);

/* global apex */
/* global CKEDITOR */

//UNE MODIF POUR COMMIT 3
var shq = shq || {};
shq.cke = {};

(function (cke, shq, ut, $) {
    //#region CONSTANTES
    /* NON SUPPORTER SUR ES6
    const UNDEFINED = "undefined";
    const EXTRA_PLUGINS_STR = ["mentions","textwatcher","autocomplete"];
    const WIDGET_NAME = "AutoCompleteWidget";
    const AUTO_COMPLETE_PLUG_IN_NAME = "autocomplete";
    const AUTO_COMPLETE_CO_BINDING_TAG = "TestCodeName";
    const TEST_CODE = "TestCo"; // TODO:  enlever quand apex prendra plus cette constante la pour parametre, mais plutot le value du champs CO (la il est null à l'init) 
    */
    //#endregion
    //#region Related Functions
    //Obligatoirement lancé dans le bloc d'initialisation de la COMPOSANTE CKEDITOR avant de pouvoir instancié le widgets avec "createAutoCompleteWidgets".

    cke.UNDEFINED = "undefined";
    cke.EXTRA_PLUGINS_STR = ["mentions","textwatcher","autocomplete"];
    cke.WIDGET_NAME = "shq_widgets.AutoCompleteWidget"; //TODO: ENLEVER le widget à la fin et aller changer les string des appèles dans apex
    cke.AUTO_COMPLETE_TAG = "autocomplete";
    cke.TEST_CODE = "TestCo";
    
    //Obligatoirement lancé de le bloc d'initialisation des CKE pour les préparer à l'initialisation.
    cke.initAutoCompletePlugInCKE = function(editorOptions,autoCompCodeNoSeq)
    {
        for(var i in cke.EXTRA_PLUGINS_STR)
        {
            editorOptions.extraPlugins += ","+ cke.EXTRA_PLUGINS_STR[i];
        }
        $("#"+editorOptions.itemName).data(cke.AUTO_COMPLETE_TAG,autoCompCodeNoSeq);
    };
    //Obligatoirement lancé dans le bloc d'initialisation de la PAGE pour instancié les widget.
    cke.createAutoCompleteWidgets = function(ckeGetDataProcessName)
    {
        function scopeFunction(){
            var asyncInstance = editors[instance];
            asyncInstance.on("instanceReady",function(evt){initFn(evt,asyncInstance);});
        }

        if (typeof(CKEDITOR) != cke.UNDEFINED)
        { 
            var editors = CKEDITOR.instances;
            for(var instance in editors)
            {
                scopeFunction();
                
            }
        }

        
        var initFn = function(ckeInst,pAsyncInstance){ //TODO: ya moyen d'utilisé juste la première je pense ici
            //Verifying that we want an auto-complete on this CKEDITOR instance by looking for the JQuery appropriate attribute. . .
            var pluginList = editors[instance].config.extraPlugins.split(",");
            console.log(pluginList);
            //if (pluginList.indexOf(cke.AUTO_COMPLETE_TAG) >= 0)
            if (typeof($("#"+instance).data(cke.AUTO_COMPLETE_TAG)) != cke.UNDEFINED)
            {
                //If found, i Create an auto-complete widget. . .
                console.log("Contient le tag autocomplete, j'instance un widget");
                $("#"+ckeInst.editor.name).AutoCompleteWidget({ckeDataProcessName : ckeGetDataProcessName, ckeInst : pAsyncInstance});
            }
            else {
                //ERROR:
                console.log("Ne contient pas le tag autocomplete");
            } 
        };
    };

    //Obligatoirement créer une action dynamic "OnChange" sur les CHAMP dont la valeur représente le CODE à utilisé pour filtré les suggestions des autocompletes.
    //Permet de garder à jour le filtre de suggestions.
    cke.updateAutoCompCodeNoSeq = function(newCode){

        if (typeof(CKEDITOR) != cke.UNDEFINED)
        { 
            var editors = CKEDITOR.instances;
            for(var instance in editors)
            {
               if (typeof($("#"+instance).data(cke.AUTO_COMPLETE_TAG)) != cke.UNDEFINED)
                {
                    //If found, i Update the code value. . .
                    console.log("Contient le tag autocomplete, je l'update");
                    var a = $("#"+instance).data("shq_widgets-AutoCompleteWidget");
                    a.setCodeNoSeq(newCode);
                }
                else {
                    //ERROR:
                    console.log("Ne contient pas le tag autocomplete");
                } 
            }
        }
    };
    //#endregion
    //#region WIDGET_DEFINITION
    $.widget(cke.WIDGET_NAME, {
        jsonData: cke.UNDEFINED,
        options: {
            ckeInst: cke.UNDEFINED,
            ckeDataProcessName: cke.UNDEFINED,
            textTestCallback: function (range) 
            {
                if (!range.collapsed){ return null; }

                return CKEDITOR.plugins.textMatch.match(range, matchCallback);
                function matchCallback(text, offset) 
                {
                    //var pattern = /\#[A-z]*/gi;
                    var pattern = /(\#)[A-z]*(?!.*\1)/i;
                    var match   = text.slice(0, offset).match(pattern);

                    if (!match){ return null; }

                    return {
                        start: match.index,
                        end: offset
                    };
                }
            },
            dataCallback: function (matchInfo, callback) 
            {
                var query = matchInfo.query.substring( 1 );//matchInfo.query.toLowerCase() //Probablement besoin de faire une propriété privé alimenter par une options au moment du init
                var data = jsonData.jsonParam.filter( 
                    function(item) {
                        //var itemName = '[[' + item.NAME + ']]';
                        return item.name.indexOf(query) == 0;
                    }
                );
                callback(data);
            },
            itemTemplate : '<li data-id="{id}">{name}</li>',
            outputTemplate : '#{name}#',//<span>&nbsp;</span>',            
        },
        _init: function () 
        {
            // Executed Before _create()
        },
        _create: function () 
        {
           // Executed after _init()
            //Preparing the data
           this._getData();

           var autocomplete = new this.window[0].CKEDITOR.plugins.autocomplete(this.options.ckeInst.widgets.editor, {
            textTestCallback: this.options.textTestCallback,
            dataCallback: this.options.dataCallback,
            itemTemplate: this.options.itemTemplate,
            outputTemplate: this.options.outputTemplate
            });

            // Override default getHtmlToInsert to enable rich content output.
            autocomplete.getHtmlToInsert = function(item) {
                return this.outputTemplate.output(item);
            };
        },		
        // Fait appel au process apex pour récupérer les donnés dans la base de donnés avec une fonction PL/SQL.
        _getData: function()
        {
            var autoCompleteCo_Val = $("#"+this.options.ckeInst.widgets.editor.name).data(cke.AUTO_COMPLETE_TAG);
            if (typeof(autoCompleteCo_Val) != cke.UNDEFINED)
            {
                console.log("Et le data attribute vaux : " + autoCompleteCo_Val);
                //Appel au process. . .
                var result = apex.server.process( this.options.ckeDataProcessName, { x01 : $("#"+this.element[0].name).data(cke.AUTO_COMPLETE_TAG)} );
                //Réaction conséquente. . .
                result.done( function( data ) { 
                    // return le value
                    console.log("Le Widget a reussis a fetch du data");
                    console.log(data);
                    jsonData = data;
                } ).fail(function( jqXHR, textStatus, errorThrown )  { 
                    // handle error 
                    //ERROR:
                    console.log("Le Widget a fail a fetch du data");
                    console.log(jqXHR);
                    console.log(textStatus);
                    console.log(errorThrown);
                } ).always( function() { 
                    // code that needs to run for both success and failure cases 
                    console.log("au moin on c'est rendue a la requete. . .");
                } );
            }
            else {
                console.log("Le data attribute pour le CO n'est pas la . . .");
                //ERROR:
            }
        },
        //Permet de changer le Code après l'initialisation!
        setCodeNoSeq: function(newCode)
        {
			var diese = '#';
			
            //TODO: AJOUTER UN PARAMETRE QUI CORRESPONDRAIT A L'ITEM DE LA PAGE POUR METTRE A JOUR LA VALEUR DU CODE et ensuite relancer le fetch de data
            $(diese+this.options.ckeInst.widgets.editor.name).data(cke.AUTO_COMPLETE_TAG,newCode);
            this._getData();
        }
    });
    //#endregion
})(shq.cke, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.date = {};

(function (shqDate, shq, ut, $) {

    shqDate.UNITE = {
        JOUR: "JOUR",
        MINUTE: "MINUTE",
        HEURE: "HEURE",
        SECONDE: "SECONDE"
    };
    /* 
     * Fonction qui fait la diffrence entre deux objets dates selon l'unité passé
    */
    shqDate.differenceEntreDeuxDate = function (pDate1, pDate2, unite) {

        var utc1 = Date.UTC(pDate1.getFullYear(), pDate1.getMonth(), pDate1.getDate());
        var utc2 = Date.UTC(pDate2.getFullYear(), pDate2.getMonth(), pDate2.getDate());
        var diffMs = Math.abs(utc1  - utc2 );
        var differenceEntreDeuxDate;

        shqDate.UNITE_FORMULE = {
            JOUR: diffMs / (1000 * 60 * 60 * 24),
            HEURE: diffMs / (1000 * 60 * 60) / 24,
            MINUTE: diffMs / (1000 * 60) / 60,
            SECONDE: diffMs / (1000) / 60
        };

        switch (unite) {
            case shqDate.UNITE.JOUR:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.JOUR);
                break;
            case shqDate.UNITE.MINUTE:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.MINUTE);
                break;                
            case shqDate.UNITE.SECONDE:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.SECONDE);
                break;
            default:
                differenceEntreDeuxDate = Math.floor(shqDate.UNITE_FORMULE.HEURE);
        }
        return differenceEntreDeuxDate;
    };

})(shq.date, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.datePicker = {};

(function (shqDatePicker, shq, ut, $) {
    var diese = '#';
    /* 
     * Fonction qui affecte la date minimum de la composante jquery datepicker
     * 
     * Exemple d'appel
     * 
     * shq.datePicker.assignerDateMinimum(["NomDeMonItemApexJquery"],apex.item("MonItemApexDateValeur").getValue());
     * 
    */
    shqDatePicker.assignerDateMinimum = function (listApexItemName, valeurDate) {

        $.each(listApexItemName, function (indexInArray, valueOfElement) {
            var $apexItemName = $(valueOfElement.indexOf(diese, 0) === -1 ? diese.concat(valueOfElement) : valueOfElement);
            $apexItemName.datepicker("option", "minDate", valeurDate);
            //
            // Permet de remettre le bouton du datepicker comme APEX.
            //  
            $apexItemName.next('button').addClass('a-Button a-Button--calendar');
        });
    };
    /* 
     * Fonction qui affecte la date maximum de la composante jquery datepicker
     * Exemple d'appel
     * 
     * shq.datePicker.assignerDateMaximum(["NomDeMonItemApexJquery"],apex.item("MonItemApexDateValeur").getValue());
     * 
    */
    shqDatePicker.assignerDateMaximum = function (listApexItemName, valeurDate) {

        $.each(listApexItemName, function (indexInArray, valueOfElement) {
            var $apexItemName = $(valueOfElement.indexOf(diese, 0) === -1 ? diese.concat(valueOfElement) : valueOfElement);
            $apexItemName.datepicker("option", "maxDate", valeurDate);
            //
            // Permet de remettre le bouton du datepicker comme APEX.
            //  
            $apexItemName.next('button').addClass('a-Button a-Button--calendar');
        });
    };

})(shq.datePicker, shq, apex.theme42, apex.jQuery);
/* global apex */

//const { validate } = require("json-schema");

var shq = shq || {};
shq.dem = {};

(function (dem, shq, ut, $) {


    dem.assignerItemsIgSelectionne = function (colonneClef, itemApex, data, modelIg) {

        var i, elements = [];
        var value;
                
        for (i = 0; i < data.selectedRecords.length; i++) {
            value = modelIg.getValue(data.selectedRecords[i], colonneClef);
            if (elements.indexOf(value)) {
                elements.push(value);
            }
        }

        apex.item(itemApex).setValue(elements.join(':'));

    };

    dem.selectionneImportationDesjardins = function (event, data) {

        var i, elements = [];
        var value;
        var model = data.model;        
        var messageApex = apex.lang.getMessage('SHQ.AVERTISSEMENT.SOURCE_FICHIER.SELECTIONNER');

        apex.message.clearErrors();
        model.forEach(function(record,index,id){
            model.setValidity("valid",id,'FILENAME');
        });
        
        for (i = 0; i < data.selectedRecords.length; i++) {
            
            value = model.getValue(data.selectedRecords[i], 'NO_SEQ_FICHIER_EXTRN');
            var id = model.getRecordId(data.selectedRecords[i]);
            var valueSourceFichier = model.getValue(data.selectedRecords[i], 'SOURCE_FICHIER');

            if (valueSourceFichier !== 'SPC2') {

                var message = apex.lang.formatNoEscape(messageApex,valueSourceFichier);
                model.setValidity( apex.message.TYPE.ERROR, id, 'FILENAME',message );
                apex.message.showErrors([{type:apex.message.TYPE.ERROR,
                                         location:"page",
                                         message: message,
                                         unsafe:true}]);

            } else {
                elements.push(value);
            }
        }

        apex.item('P21_SELECTED_IG').setValue(elements.join(':'));

    };

    dem.sauvegarde_conseil_adm = function () {

        var vta_prenom_membre_ca = [];
        var vta_nom_membre_ca = [];
        var vta_no_seq_carac_ca = [];
        var vta_precision = [];
        var pThis;

        //obtenir la liste  des prenoms
        $('.cair_prenom_membre_ca').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_prenom_membre_ca.push(pvalue);
        });

        //obtenir la liste des noms
        $('.cair_nom_membre_ca').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_nom_membre_ca.push(pvalue);
        });

        //obtenir la liste des identifiants
        $('.cair_no_seq_carac_ca').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_no_seq_carac_ca.push(pvalue);
        });

        //obtenir la liste des precisions
        $('.cair_precision').each(function () {
            pThis = $(this);
            pvalue = pThis.val();
            vta_precision.push(pvalue);
        });

        apex.server.process("SAVE_CA", {
            f01: vta_no_seq_carac_ca,
            f02: vta_prenom_membre_ca,
            f03: vta_nom_membre_ca,
            f04: vta_precision,
            pageItems: "#P4_NO_SEQ_DEMAN_PHAQ,#P4_IND_CONSEIL_ADMINISTRATION"
        }, {
            success: function (pData) {
                apex.region('conseilAdm').refresh();
            }
        });

    };

})(shq.dem, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.dem_public = {};

(function (dem_public, shq, ut, $) {

    var GRID_LOGEMENT_SUPERFICIE = "SuperficieLogement";
    var diese = '#';

    dem_public.souscrireSuperficieLogement = function () {
        // the model gets released and created at various times such as when the report changes
        // listen for model created events so that we can subscribe to model notifications
        var $id = $(diese.concat(GRID_LOGEMENT_SUPERFICIE));

        $id.on("interactivegridviewmodelcreate", function (event, ui) {
            var sid,
                model = ui.model;
            // note this is only done for the grid veiw. It could be done for
            // other views if desired. The important thing to realize is that each
            // view has its own model
            if (ui.viewId === "grid") {
                sid = model.subscribe({
                    onChange: function (type, change) {
                        var actions = apex.region(GRID_LOGEMENT_SUPERFICIE).call("getActions");
                        if (apex.page.isChanged()) {
                            actions.disable('generer-logement');
                        } else {
                            actions.enable('generer-logement');
                        }   
                    },
                    progressView: this.element
                });
            }
        });

    };
    //
    // configuration de la barre d'outils de la grid interactive Pour la superficie.
    //   
    dem_public.configurerBarreOutilsSuperficie = function (config) {
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
        var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

        var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
        var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        var saveAction = toolbarData.toolbarFind("save");
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        //
        // Bouton Ajouter
        //
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        //
        // Bouton save
        //  
        saveAction.icon = "fa fa-save fam-arrow-down fam-is-info";
        saveAction.label = "Superficie";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        //
        // Bouton Annuler modification
        //
        var modelBoutonAnnulerModif = {
            type: "BUTTON",
            name: "annuler-ligne",
            label: "Annuler",
            action: "selection-revert",
            icon: "fa fa-undo",
            iconBeforeLabel: true,
            hot: false
        };

        toolbarGroupAction3.push(modelBoutonAnnulerModif);
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton télecharger
        // 
        var modelBoutonTelecharger = {
            type: "BUTTON",
            name: "telecharger",
            label: "Télécharger",
            action: "show-download-dialog" ,
            icon: "fa fa-download",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction2.push(modelBoutonTelecharger);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);
        //
        // Bouton Générer logement
        //  
        config.initActions = function (actions) {
            actions.add({
                name: "generer-logement",
                label: "Générer logement",
                action: function (even, ui) {
                    if (!apex.item("P200_URL_PAGE_GENERER_LOGEMENT").isEmpty()) {
                        var itemUrl = apex.item("P200_URL_PAGE_GENERER_LOGEMENT");
                        var url = itemUrl.getValue();
                        apex.navigation.redirect(url);
                    }
                }
            });
        };

        var modelBoutonGenererLogement = {
            type: "BUTTON",
            action: "generer-logement",
            icon: "fa fa-gears",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonGenererLogement);
        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };

        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };


    //
    // configuration de la barre d'outils de la grid interactive Pour la superficie.
    //   
    dem_public.configurerBarreOutilsAutresSuperficie = function (config) {
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
        var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

        var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
        var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        var saveAction = toolbarData.toolbarFind("save");
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        //
        // Bouton Ajouter
        //
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        //
        // Bouton save
        //  
        saveAction.icon = "fa fa-save fam-arrow-down fam-is-info";
        saveAction.label = "Superficie";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        //
        // Bouton Annuler modification
        //
        var modelBoutonAnnulerModif = {
            type: "BUTTON",
            name: "annuler-ligne",
            label: "Annuler",
            action: "selection-revert",
            icon: "fa fa-undo",
            iconBeforeLabel: true,
            hot: false
        };

        toolbarGroupAction3.push(modelBoutonAnnulerModif);
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);
        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };

        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };

    //
    // configuration de la barre d'outils de la grid interactive Pour la superficie.
    //   
    dem_public.configurerBarreOutilsRepartition = function (config) {
        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
        var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

        var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
        var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        var saveAction = toolbarData.toolbarFind("save");
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        //
        // Bouton Ajouter
        //
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        //
        // Bouton save
        //  
        saveAction.icon = "fa fa-save fam-arrow-down fam-is-info";
        saveAction.label = "Répartition";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        //
        // Bouton Annuler modification
        //
        var modelBoutonAnnulerModif = {
            type: "BUTTON",
            name: "annuler-ligne",
            label: "Annuler",
            action: "selection-revert",
            icon: "fa fa-undo",
            iconBeforeLabel: true,
            hot: false
        };

        toolbarGroupAction3.push(modelBoutonAnnulerModif);
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);

        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };

        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };
})(shq.dem_public, shq, apex.theme42, apex.jQuery);
/* global apex */

//const { default: validation } = require("ajv/dist/vocabularies/validation");

var shq = shq || {};
shq.fdt = {};



(function (fdt, shq, ut, $) {

    "use strict";

    var diese = '#';
    var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
    var FORMAT_DATE_HEURE = 'YYYY-MM-DD HH24:MI';
    var GRID_TEMPSSAISIEPERIODE = "tempsSaisiePeriode";
    var GRID_TEMPSINTERVENTION = "tempsIntervention";
    // 
    // Fonction qui valide les heures AM
    // 
    fdt.validerHeureAM = function (model, change) {
        apex.debug.info('On change validerHeureAM');

        // Élément modifié
        var heureDebutAm = model.getValue(change.record, "DH_DEBUT_AM_TEMPS_SAISIE");
        var heureFinAm = model.getValue(change.record, "DH_FIN_AM_TEMPS_SAISIE");
        var dateEnSaisieAm = model.getValue(change.record, "DT_TEMPS_JOUR");
        if (Boolean(heureDebutAm) && Boolean(heureFinAm)) {
            var dateDebutAm = apex.date.parse(dateEnSaisieAm + ' ' + heureDebutAm, FORMAT_DATE_HEURE);
            var dateFinAm = apex.date.parse(dateEnSaisieAm + ' ' + heureFinAm, FORMAT_DATE_HEURE);
            var heureDebutApresFinAm = apex.date.isAfter(dateDebutAm, dateFinAm);
            var apexItem = apex.item(change.field);
            if (heureDebutApresFinAm) {
                apexItem.node.setCustomValidity(apex.lang.getMessage("SHQ.ITEM.HEURE_INCOHERENTE"));
            } else {
                apexItem.node.setCustomValidity("");
            }
        }
    };
    // 
    // Fonction qui valide les heures PM
    // 
    fdt.validerHeurePM = function (model, change) {
        apex.debug.info('On change validerHeurePM');

        // Élément modifié

        var heureDebutPm = model.getValue(change.record, "DH_DEBUT_PM_TEMPS_SAISIE");
        var heureFinPm = model.getValue(change.record, "DH_FIN_PM_TEMPS_SAISIE");
        var dateEnSaisiePm = model.getValue(change.record, "DT_TEMPS_JOUR");

        if (Boolean(heureDebutPm) && Boolean(heureFinPm)) {
            var dateDebutPm = apex.date.parse(dateEnSaisiePm + ' ' + heureDebutPm, FORMAT_DATE_HEURE);
            var dateFinPm = apex.date.parse(dateEnSaisiePm + ' ' + heureFinPm, FORMAT_DATE_HEURE);
            var heureDebutApresFinPm = apex.date.isAfter(dateDebutPm, dateFinPm);
            var apexItem = apex.item(change.field);
            if (heureDebutApresFinPm) {
                apexItem.node.setCustomValidity(apex.lang.getMessage("SHQ.ITEM.HEURE_INCOHERENTE"));
            } else {
                apexItem.node.setCustomValidity("");
            }
        }
    };
    // 
    // Fonction qui met en évidence les enregistrement fériés.
    // 
    fdt.appliquerMiseEnEvidenceEnregistrement = function (model) {

        var cssFeriee = apex.lang.getMessage("FDT.CSS.FERIEE");

        model.forEach(function (record, index, id) {
            var journeeFerrie = model.getValue(record, "INDIC_FERIEE");
            var meta = model.getRecordMetadata(id);

            meta.highlight = journeeFerrie === 'O' ? cssFeriee : '';
        });
    };
    //
    // This is the general pattern for subscribing to model notifications
    //
    // need to do this here rather than in Execute when Page Loads so that the handler
    // is setup BEFORE the IG is initialized otherwise miss the first model created event
    fdt.souscrireFeuilleDeTemps = function () {
        // the model gets released and created at various times such as when the report changes
        // listen for model created events so that we can subscribe to model notifications
        var $id = $(diese.concat(GRID_TEMPSSAISIEPERIODE));

        $id.on("interactivegridviewmodelcreate", function (event, ui) {
            var sid,
                model = ui.model;
            // note this is only done for the grid veiw. It could be done for
            // other views if desired. The important thing to realize is that each
            // view has its own model
            if (ui.viewId === "grid") {
                fdt.appliquerMiseEnEvidenceEnregistrement(model);
                sid = model.subscribe({
                    onChange: function (type, change) {
                        var heureAM = ['DH_DEBUT_AM_TEMPS_SAISIE', 'DH_FIN_AM_TEMPS_SAISIE'];
                        var heurePM = ['DH_DEBUT_PM_TEMPS_SAISIE', 'DH_FIN_PM_TEMPS_SAISIE'];
                        if (type === "set") {
                            // don't bother to recalculate if other columns change
                            if (heureAM.indexOf(change.field) > -1) {
                                fdt.validerHeureAM(model, change);
                            } else if (heurePM.indexOf(change.field) > -1) {
                                fdt.validerHeurePM(model, change);
                            }
                        }
                        fdt.appliquerMiseEnEvidenceEnregistrement(model);
                    },
                    progressView: this.element
                });
            }
        });

    };
    //
    // Sélection des périodes dans la  page de saisie du temps 
    // 
    fdt.selectionPeriode = function (pRegionContainer, pIndexTab, pDebutPeriodeItem, pDebutPeriodeVal, pFinPeriodeItem, pFinPeriodeVal) {

        var TAB_CONTAINER_CLASS = 't-Tabs',
            TAB_ITEM_CLASS = 't-Tabs-item',
            IS_CURRENT_CLASS = 'is-active';

        //enlever la classe is-active de l'ancien élément sélectionné

        $('#' + pRegionContainer).find('.' + TAB_ITEM_CLASS + '.' + IS_CURRENT_CLASS).removeClass(IS_CURRENT_CLASS);

        //ajouter la classe is-active sur l'élément sélectionné

        $('#' + pRegionContainer).find('.' + TAB_ITEM_CLASS).eq(pIndexTab).addClass(IS_CURRENT_CLASS);
        apex.item(pDebutPeriodeItem).setValue(pDebutPeriodeVal);
        apex.item(pFinPeriodeItem).setValue(pFinPeriodeVal);
        apex.item('P2_REFRESH_FDT_INTERVENTION').setValue(pIndexTab);
    };
    //
    // Mise à jour du lien pour l'ajout d'absence
    // 
    fdt.obtenirHrefAjouterAbsence = function () {
        var itemUrl = apex.item("P2_URL_PAGE_ABSENCE");
        var url = itemUrl.getValue();

        return url;
    };
    // 
    // Configuration de la barre d'outils de la feuille de temps     
    //
    fdt.configurerSaisieTemps = function (config) {

        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar  
        // 
        // section de la toolbar
        //    
        var toolbarGroupAction1 = toolbarData.toolbarFind("actions1").controls,
            toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls,
            toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls,
            toolbarGroupAction4 = toolbarData.toolbarFind("actions3").controls;
        //
        // Constantes
        //
        var OUI = 'O',
            NON = 'N',
            ABSENCE = 'ABS',
            VACANCE = 'VAC';
        //
        // Boutons annuler modif
        //
        //var modelBoutonAnnulerModif = {
        //    type: "BUTTON",
        //    name: "annuler-ligne",
        //    label: "Annuler",
        //    action: "selection-revert",
        //    icon: "fa fa-undo",
        //    iconBeforeLabel: true,
        //    hot: false
        //};

        //toolbarGroupAction3.push(modelBoutonAnnulerModif);
        //
        // Bouton Enregistrer
        // 
        var saveAction = toolbarData.toolbarFind("save");
        saveAction.icon = "fa fa-table fam-arrow-down fam-is-info";
        saveAction.label = "Enregistrer mon temps ";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        toolbarGroupAction3.push(saveAction);
        //
        // fonctions Filtre
        // 
        var actionFiltre = function (event, element) {

            var itemFiltreAbscence = apex.item("P2_FILTRE_TEMPS_SAISIE_ABS");
            var itemFiltreVacance = apex.item("P2_FILTRE_TEMPS_SAISIE_VAC");
            //
            // Détrermine quel bouton a été cliqué
            //         
            var dataAction = this.name;

            var itemvaleur;
            var item;

            switch (dataAction) {
                case 'filtre-absence':
                    itemvaleur = ABSENCE;
                    item = itemFiltreAbscence;
                    break;
                case 'filtre-vacance':
                    itemvaleur = VACANCE;
                    item = itemFiltreVacance;
                    break;
                default:
                    itemFiltre.setValue(null);
            }

            if (this.get()) {
                item.setValue('');
                this.set(false);
                $(element).removeClass("is-active-filtre-fdt");
            } else {
                item.setValue(itemvaleur);
                this.set(true);
                $(element).addClass("is-active-filtre-fdt");
            }

            apex.region(GRID_TEMPSSAISIEPERIODE).refresh();

            return this.get();

        };
        //
        // Appel de la page de saisie des absences
        //  
        var dialogueAbsence = function () {
            var url = fdt.obtenirHrefAjouterAbsence();
            apex.navigation.redirect(url);
        };
        //
        // Process qui sauvegarde la grid passé en paramètre.
        // 
        var processSave = function (ig, grid) {

            return new Promise(function (resolve, reject) {
                //
                // Si il y a des erreurs sur la gird alors on fait rien
                // 
                if (grid.model.hasErrors()) {
                    reject(false);
                } else {

                    var modelProcessSave = grid.model.save(resolve(true));
                    //
                    // Sauvegarde en cour ou rien à mettre à jour 
                    //
                    if (!modelProcessSave) {
                        resolve(true);
                    }
                }
            });
        };
        //
        // Boutons Filtre
        //        
        config.initActions = function (actions) {

            actions.add([{
                name: "filtre-absence",
                label: 'Absence',
                state: false,
                action: actionFiltre,
                get: function () {
                    return this.state;
                },
                set: function (v) {
                    this.state = v;
                    return this.state;
                }
            },
            {
                name: "filtre-vacance",
                label: 'Vacances',
                state: false,
                action: actionFiltre,
                get: function () {
                    return this.state;
                },
                set: function (v) {
                    this.state = v;
                    return this.state;
                }

            },
            //
            // définition de l'action du bouton Ajouter absence
            // 
            {
                name: "ajouter-absence",
                label: "Absence",
                action: function (event, el) {
                    //
                    // EA_RESSOURCE_SAISI_INTRV est une constante déclarer dans la page dans le
                    // Function and Global Variable Declaration
                    //                                         
                    var indicateurMoisComplet = apex.item("P2_IND_MOIS_COMPLET_INTERV").getValue(),
                        igTempsPeriode = apex.region(GRID_TEMPSSAISIEPERIODE),
                        gridTempPeriode = igTempsPeriode.call("getViews").grid,
                        igIntervention,
                        gridIntervention;

                    var promiseTempsPeriode = processSave(igTempsPeriode, gridTempPeriode),
                        promiseIntervention,
                        arrayPromise = new Array(0);

                    if (indicateurMoisComplet == 'N' &&
                        EA_RESSOURCE_SAISI_INTRV === 'O') {

                        igIntervention = apex.region(GRID_TEMPSINTERVENTION);
                        gridIntervention = igIntervention.call("getViews").grid;
                        promiseIntervention = processSave(igIntervention, gridIntervention);
                        arrayPromise.push(promiseTempsPeriode, promiseIntervention);
                    } else {
                        igIntervention = null;
                        gridIntervention = null;
                        promiseIntervention = null;
                        arrayPromise.push(promiseTempsPeriode);
                    }

                    Promise.all(arrayPromise).then(function (retours) {
                        if (retours.every(Boolean)) {
                            dialogueAbsence();
                        }
                    })
                        .catch(function (error) {
                            shq.page.alert(apex.lang.getMessage("FDT.ABSENCE.ERREUR"));
                        });
                }
            }]);
        };
        //
        // définition des boutons personnalisés de la grid
        // 
        var modelBoutonAjouterAbsence = {
            type: "BUTTON",
            icon: "fa fa-plus",
            action: "ajouter-absence",
            iconBeforeLabel: true,
            hot: true
        };

        var modelBoutonFiltreAbsence = {
            type: "BUTTON",
            action: "filtre-absence",
            icon: 'fa fa-filter',
            iconBeforeLabel: true,
        };

        var modelBoutonFiltreVacance = {
            type: "BUTTON",
            action: 'filtre-vacance',
            icon: 'fa fa-filter',
            iconBeforeLabel: true

        };
        //
        // Ajout des boutons filtres sur la grid.
        //     
        toolbarGroupAction2.push(modelBoutonFiltreAbsence);
        toolbarGroupAction2.push(modelBoutonFiltreVacance);
        //
        // Détermine si on affiche le bouton absence selon l'indicateur interne ou externe de la personne ressource
        // 
        var indicateurAjoutBoutonAbsence = function () {
            //
            // La variable EA_INTERNE_OU_EXTERNE est déclaré dans la page 2 dans Function and Global Variable Declaration
            //  
            if (EA_INTERNE_OU_EXTERNE === 'I') {
                return true;
            } else {
                return false;
            }
        };

        if (indicateurAjoutBoutonAbsence()) {
            toolbarGroupAction4.push(modelBoutonAjouterAbsence);
        }        
        //
        // Ajout du mode skipReadonlyCells
        // 
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };
        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };
    // 
    // Configuration de la barre d'outils de la feuille de temps des intervention    
    //
    fdt.configurerSaisieIntervention = function (config) {

        var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar  
        // 
        // section de la toolbar
        //    
        var toolbarGroupAction1 = toolbarData.toolbarFind("actions1").controls,
            toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls,
            toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;           
        //
        // Bouton Ajouter
        //            
        var addrowAction = toolbarData.toolbarFind("selection-add-row");
        addrowAction.label = "Ajouter";
        addrowAction.icon = "fa fa-plus";
        addrowAction.iconBeforeLabel = true;
        addrowAction.hot = true;
        // toolbarGroupAction3.push(modelBoutonAnnulerModif);
        //
        // Bouton Enregistrer
        // 
        var saveAction = toolbarData.toolbarFind("save");
        saveAction.icon = "fa fa-table fam-arrow-down fam-is-info";
        saveAction.label = "Enregistrer";
        saveAction.iconBeforeLabel = true;
        saveAction.hot = true;
        toolbarGroupAction2.pop();
        toolbarGroupAction3.push(saveAction);
        //
        // Bouton Supprimer
        //
        var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
        };
        toolbarGroupAction3.push(modelBoutonSupprimer);
        //
        // Ajout du mode skipReadonlyCells
        // 
        var skipReadonlyCells = {
            skipReadonlyCells: true,
        };
        config.defaultGridViewOptions = config.defaultGridViewOptions || {};
        $.extend(config.defaultGridViewOptions, skipReadonlyCells);
        //
        // retourne la config
        //
        config.toolbarData = toolbarData;
        return config;
    };

})(shq.fdt, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.gpr = {};

(function (shq, gpr, util, $) {
   "use strict";

   gpr.ajusterFocusContactClient =  function(itemContactClient)  {
      var coTypClient = apex.item(itemContactClient).getValue();
      var idFocusNombre;
      var selectorJq = "label[for=\"".concat(itemContactClient).concat("_idFocusNombre\"");

      switch (coTypClient) {
         case 'DOMIC':
            // code block
            idFocusNombre = '0';
            break;
         case 'BURE':
            // code block
            idFocusNombre = '1';
            break;
         case 'CELL':
            // code block
            idFocusNombre = '2';
            break;
         case 'TELEA':
            // code block
            idFocusNombre = '3';
            break;
         case 'FAX':
            // code block
            idFocusNombre = '4';
            break;
         default:
            // code block
            // Autre
            idFocusNombre = '5';
      }
      selectorJq = selectorJq.replace('idFocusNombre', idFocusNombre);
      $(selectorJq).focus();
   };
   //
   // Ajuster le focus sur le pills buttons de l'adresse
   //
   gpr.ajusterFocueTypClient = function (itemTypClient) {
      var coTypClient = apex.item(itemTypClient).getValue();
      var idFocusNombre;
      var selectorJq = "label[for=\"P18_CO_TYP_CLIENT_idFocusNombre\"";

      switch (coTypClient) {
         case 'COPR':
            // code block
            idFocusNombre = '1';
            break;
         case 'REPO':
            // code block
            idFocusNombre = '2';
            break;
         default:
            // code block
            // Propriétaire
            idFocusNombre = '0';
      }
      selectorJq = selectorJq.replace('idFocusNombre', idFocusNombre);
      $(selectorJq).focus();
   };
})(shq, shq.gpr, apex.util, apex.jQuery);
/* global apex */
/* global moment */

var shq = shq || {};
shq.pil = {};

(function (shq, pil, util, $) {
   "use strict";

   var C_GRID = "grid",
      C_SET = "set";

   pil.calculerNombrejour = function (model, recordId) {

      var C_DAYS = "days";
      var meta = model.getRecordMetadata(recordId);
      var rec = model.getRecord(recordId);

      if (meta.inserted || meta.updated) {
         /*
          * Force un objet moment à null pour qu'il soit volontairement invalide 
          */
         var dtDebut = model.getValue(rec, "DT_DEBUT_AN").lenght === 0 ? moment(null) : moment(model.getValue(rec, "DT_DEBUT_AN"));
         var dtFin = model.getValue(rec, "DT_FIN_AN").lenght === 0 ? moment(null) : moment(model.getValue(rec, "DT_FIN_AN"));

         if (dtDebut.isValid() && dtFin.isValid() && dtDebut.isBefore(dtFin)) {
            dtFin.add(1, C_DAYS);
            /*
             * Le setValue prends une valeur en sting seulement, corrigé dans les versions supérieurs
             */
            var nbjour = dtFin.diff(dtDebut, C_DAYS).toString();
            model.setValue(rec, "NB_JOUR", nbjour);
         }
      }

   };

   pil.gridCalendrierPil = function () {

      $("#calendrierPil").on("interactivegridviewmodelcreate", function (event, ui) {
         // eslint-disable-next-line no-unused-vars
         var sid,
            model = ui.model;
         
         if (ui.viewId === C_GRID) {
            sid = model.subscribe({
               /* 
                * Bind l'événement change au model de la grid 
                */
               onChange: function (type, change) {

                  var dateColonnes = ['DT_DEBUT_AN', 'DT_FIN_AN'];

                  if (type === C_SET) {
                     if (dateColonnes.indexOf(change.field) > -1) {
                        setTimeout(function () {
                           pil.calculerNombrejour(model, change.recordId);
                        }, 0);
                     }
                  }
               }
            });
         }
      });
   };
})(shq, shq.pil, apex.util, apex.jQuery);
/* 
   * plug pour ie 11. À retirer à partir de juin 2022
   */

//
// Polyfill pour la finction includes
// 
if (!String.prototype.includes) {
    String.prototype.includes = function(search, start) {
      'use strict';
   
      if (search instanceof RegExp) {
        throw TypeError('first argument must not be a RegExp');
      }
      if (start === undefined) { start = 0; }
      return this.indexOf(search, start) !== -1;
    };
   }

/* global apex */


var shq = shq || {};
shq.psa  = {};

(function (psa, shq, ut, $) {
  
   //
   // Modifie la valeur du label sur les valeurs égale à 0 dans le graphique.
   // 
   psa.graph_subLabelValeurEgaleA0 = function (options,subString) 
   {
        options.dataFilter = function(data)
        {
            /*for (var serie of data.series) // NON SUPPORTER PAR Internet explorer
            {
                for (var item of serie.items)
                {
                    if(item.value == 0) 
                    {
                        item.label = subString;
                    }
                }
            }*/
            var serie;
            var item;
            for (serie in data.series)
            {
                for (item in data.series[serie].items)
                {
                    if(data.series[serie].items[item].value == 0)
                    {
                        data.series[serie].items[item].label = subString;
                    }
                }
            }
            return data;
        };
        return options;
   };
})(shq.psa, shq, apex.theme42, apex.jQuery);

/*******************************************************************************
 *                Registre des modifications
 * Date           Nom                     Description
 * 2018-05-22     Michel Lessard          Création initiale
 ******************************************************************************/

/*******************************************************************************
 * Initialiser la variable de namespace shq
 ******************************************************************************/

/* global apex */

var shq = shq || {};


//
//
//

(function (shq, apex, util, $) {
   "use strict";


   //Permettre de définir le titre d'une page modal
   //Le code doit être exécuté par la page modal
   shq.definirTitreModal = function (pTitre) {
      util.getTopApex().$(".ui-dialog-content").dialog("option", "title", pTitre);
   };

   //Permet d'afficher les sous-éléments d'un menu sur le click de clui-ci
   function _initNavMenuAccordion() {
      //
      //Accordion-Like Navigation Menu: Menu avec lien égal à '#'
      //
      $('#t_Body_nav #t_TreeNav').on('click', 'ul li.a-TreeView-node div.a-TreeView-content:has(a[href="#"])', function () {
         $(this).prev('span.a-TreeView-toggle').click();
      });
      //
      //Accordion-Like Navigation Menu: Menu sans lien
      //
      $('#t_Body_nav #t_TreeNav').on('click', 'ul li.a-TreeView-node div.a-TreeView-content:not(:has(a))', function () {
         $(this).prev('span.a-TreeView-toggle').click();
      });
      // 
      // Permet de mettre un title sur les items de menu.
      // 
      if ($("#t_TreeNav").treeView !== undefined) {
         $("#t_TreeNav").treeView({
            tooltip: {
               show: { delay: 1000, effect: "blind", duration: 800 },
               content: function (callback, node) {
                  return node.label;
               }
            }
         });
      }
   }
   //
   function _fixMessageClose() {
      var APEX_SUCCESS_MESSAGE = "#APEX_SUCCESS_MESSAGE",
         C_BTN_FERMR_MESG = 't-Button--closeAlert',
         S_BTN_FERMR_MESG = '.' + C_BTN_FERMR_MESG;

      var msg$ = $(APEX_SUCCESS_MESSAGE);

      msg$.find(S_BTN_FERMR_MESG).click(function () {
         apex.message.hidePageSuccess();
      });
   }
   //
   function _autoDismissMessage() {
      var opt = {
         autoDismiss: true,
         duration: 4000
      };
      //
      // this only applys configuration when base page has a process success message ready to display
      //
      apex.theme42.configureSuccessMessages(opt);
      _fixMessageClose();

      apex.message.setThemeHooks({
         beforeShow: function (pMsgType) {
            if (pMsgType === apex.message.TYPE.SUCCESS) {
               apex.theme42.configureSuccessMessages(opt);
               _fixMessageClose();
            }
         }
      });
   }
   //
   // Détection du browser 
   //   
   // Chrome
   shq.isNavigateurChrome = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("Chrome") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   // Iexplorer 11
   //
   shq.isNavigateurIexplorer11 = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("/MSIE|Trident/") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   // firefox
   //   
   shq.isNavigateurFirefox = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("Firefox") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   // Safari
   //
   shq.isNavigateurSafari = function () {

      var isSafari = /constructor/i.test(window.HTMLElement) ||
         (function (p) {
            return p.toString() === "[object SafariRemoteNotification]";
         })
            (!window.safari ||
               (typeof safari !== 'undefined' && safari.pushNotification));

      return isSafari;
   };
   //
   // Edge
   //
   shq.isNavigateurEdge = function () {
      var userAgent = navigator.userAgent;
      var blBrowser = false;
      if (userAgent.search("Edg/") > 0) {
         blBrowser = true;
      }
      return blBrowser;
   };
   //
   //Execution au Chargement de la page
   //
   $(document).ready(function () {
       _initNavMenuAccordion();
       _autoDismissMessage();
    }); 

})(shq, apex, apex.util, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.dialog = {};

(function (dialog, shq, ut, $) {
   "use strict";
   dialog.confirmeFermetureDialog = function (event, ui) {
      var l_original_bouton_Ok = apex.lang.getMessage("APEX.DIALOG.OK");
      var l_nouveau_bouton_ok = apex.lang.getMessage("SHQ.DIALOG.WARNONSAVE.QUITTER");
      var message = apex.lang.getMessage("APEX.WARN_ON_UNSAVED_CHANGES");

      //change le libellé des boutons
      apex.lang.addMessages({ "APEX.DIALOG.OK": l_nouveau_bouton_ok });

      if (apex.page.isChanged()) {
         apex.message.confirm(message, function (okPressed) {
            if (okPressed) {
               apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_bouton_Ok });
               apex.navigation.dialog.close(true);
            }
         });
      } else {
         apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_bouton_Ok });
         apex.navigation.dialog.close(true);
      }

   };   
   dialog.validerFermetureDialogue = function (elementDialogue) {
      var uiDialogueNotification = 'ui-dialog--notification';
      var uiDialogueInline = 'ui-dialog--inline';
  
      var classList = elementDialogue.target.parentElement.classList;
  
      return $.inArray(uiDialogueNotification, classList) === -1 &&
        $.inArray(uiDialogueInline, classList) === -1;
    };    
})(shq.dialog, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.ig = {};

(function (ig, shq, ut, $) {
   "use strict";
   var diese = '#';
   var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;

   //
   // Obtenir une la valeur d'une cellule correspondant au record courant et à un nom de colonne.
   // 
   ig.obtenirValeurColonneRecordCourant = function (nomGrille, nomColonne) {
      var valeur = "";

      var widget = apex.region(nomGrille).widget();
      if (!(widget && widget !== "null" && widget !== "undefined")) {
         return ("");
      }

      var grid = widget.interactiveGrid('getViews', 'grid');
      if (!(grid && grid !== "null" && grid !== "undefined")) {
         return ("");
      }

      var model = grid.model;
      if (!(model && model !== "null" && model !== "undefined")) {
         return ("");
      }

      var selectedRecords = grid.getSelectedRecords();

      if (selectedRecords.length == 1) {
         valeur = model.getValue(selectedRecords[0], nomColonne);
      }

      return (valeur);
   };
   //
   // Définir la valeur par defaut pour une colonne d'une grid interactive
   // 
   ig.definirValeurDefautColonne = function (nomGrille, nomColonne, valeurDefaut) {

      var appliquerdefaut = true;

      var widget = apex.region(nomGrille).widget();
      if (!(widget && widget !== "null" && widget !== "undefined")) {
         appliquerdefaut = false;
      }

      var grid = widget.interactiveGrid('getViews', 'grid');
      if (!(grid && grid !== "null" && grid !== "undefined")) {
         appliquerdefaut = false;
      }

      var model = grid.model;
      if (!(model && model !== "null" && model !== "undefined")) {
         appliquerdefaut = false;
      }

      var igFields = model.getOption("fields").nomColonne;
      if (!(igFields && igFields !== "null" && igFields !== "undefined")) {
         appliquerdefaut = false;
      }

      if (appliquerdefaut) {
         model.getOption("fields").nomColonne.defaultValue = valeurDefaut;
      }
   };
   //
   // Permet de rengre une IG éditable ou non. Gère aussi l'affichage et des boutons concernés.
   // 
   ig.activerDesactiverEditable = function (igStaticID, activer) {
      if (igStaticID !== undefined && activer !== undefined) {

         var actions = ["edit", "selection-add-row", "selection-delete", "selection-duplicate", "row-add-row", "row-delete", "row-duplicate", "insert-record", "delete-record", "selection-revert"];
         apex.region(igStaticID).call("getCurrentView").model.setOption("editable", activer);

         actions.forEach(function (item) {
            switch (activer) {
               case true:
                  apex.region(igStaticID).call("getActions").show(item);
                  break;
               case false:
                  apex.region(igStaticID).call("getActions").hide(item);
                  break;
               default:
            }
         });
      }
   }; //Fin ig.activerDesactiverEditable
   //
   // Permet de d'activer l'option d'ajouter une ligne dans une grid.
   // 
   ig.activerDesactiverAjouterLigne = function (igStaticID, activer) {
      if (igStaticID !== undefined && activer !== undefined) {

         var actions = ["selection-add-row", "row-add-row", "row-duplicate", "selection-duplicate"];

         actions.forEach(function (item) {
            switch (activer) {
               case true:
                  apex.region(igStaticID).call("getActions").enable(item);
                  break;
               case false:
                  apex.region(igStaticID).call("getActions").disable(item);
                  break;
               default:
            }
         });
      }
   }; //Fin ig.activerDesactiverAjouterLigne
   //
   // Modifie la visibilité des colonnes passer en paramètre pour la région donné.
   // 
   ig.modifierVisibiliteColonnes = function (colArray, gridRegionId, visibility) {
      var gridView = apex.region(gridRegionId).call("getViews").grid;
      var gridView$ = gridView.view$;

      gridView.getColumns().forEach(function (element) {
         /*
         //if(colArray.includes(x.property)) -- Non supporté par IExplorer. . .
         */
         if (colArray.indexOf(element.property) >= 0) {
            if (visibility) {
               gridView$.grid("showColumn", element.property);
            }
            else {
               gridView$.grid("hideColumn", element.property);
            }
         }
      });
   };
   //
   // Configuration le tooltips des colonnes 
   // 
   ig.configTooltipColonne = function (options, listColonne) {
      options.defaultGridViewOptions = options.defaultGridViewOptions || {};
      var gridOptions = {
         tooltip: {
            content: function (callback, model, recordMeta, colMeta, columnDef) {
               var text;
               if (columnDef && recordMeta) {
                  if ($.inArray(columnDef.property, listColonne) >= 0) {
                     text = model.getValue(recordMeta.record, columnDef.property);
                  }
               }
               return text;
            }
         }
      };

      $.extend(options.defaultGridViewOptions, gridOptions);
      return options;
   };
   //
   // Configuration de la largeur de la colonne 
   // 
   ig.configColonneStretch = function (options, blStretch, largeur) {
      options.defaultGridColumnOptions = options.defaultGridColumnOptions || {};
      var configColonne;

      if (largeur !== undefined && largeur > 0) {
         configColonne = {
            noStretch: blStretch,
            width: largeur
         };
      }
      $.extend(options.defaultGridColumnOptions, configColonne);
      return options;
   };
   //
   // Mets un numéro de séquence comme première colonne
   // 
   ig.configColonneRowHeaderSequence = function (options) {
      options.defaultGridViewOptions = options.defaultGridColumnOptions || {};
      var rowHeader = {
         multiple: false,
         hideControl: true,
         rowHeader: "sequence"
      };
      $.extend(options.defaultGridViewOptions, rowHeader);
      return options;
   };
   //
   // Configuration da la colonne APEX$ROW_ACTION
   //
   ig.configApexRowAction = function (config) {
      config.defaultGridColumnOptions = config.defaultGridColumnOptions || {};
      // Désactive la sélection de l'entête de colonne. Empêche son déplacement
      var rowAction = {
         noHeaderActivate: true,
         usedAsRowHeader: false
      };
      //
      // Retour de la config de la colonne.
      // 
      $.extend(config.defaultGridColumnOptions, rowAction);
      return config;
   };
   //
   // Configuration da la colonne Edition Lien 
   // 
   ig.configurerOptionEditionLienIg = function (config) {
      config.defaultGridColumnOptions = config.defaultGridColumnOptions || {};
      // Désactive la sélection de l'entête de colonne pour l'edition d'un enregistrement.      
      var editionLien = {
         noHeaderActivate: true,
         label: '',
         noStretch: true,
         width: 45
      };
      //
      // Retire la possibilité d'enlever la colonne.
      //
      if (config.features !== undefined) {
         config.features.canHide = false;
      }
      //
      // Retour de la config de la colonne.
      // 
      $.extend(config.defaultGridColumnOptions, editionLien);
      return config;
   };
   // 
   // Ajout du bouton ajouter pour une boite de dialogue 
   // 
   ig.configurerBoutonAjouterDialogue = function (config) {
      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
      var toolbarGroup = toolbarData.toolbarFind("actions3").controls;

      toolbarGroup.push({
         type: "BUTTON",
         action: "ajouter-valeur-parametre",
         iconBeforeLabel: true
      });
      config.toolbarData = toolbarData;
      return config;
   };
   //
   // Retire l'option d'aggrégation dans la boite option
   // 

   //
   // configuration de la barre d'outils de la grid interactive.
   //   
   ig.configurerBarreOutilsBoutons = function (config, boutonAnnuler, boutonSupprimer, boutonSave) {
      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
      var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

      /* indique si la grid on peut ajouter des données */
      var boutonAjouter = false;


      if (config.editable !== undefined) {
         if (config.editable.allowedOperations.create === undefined) {
            boutonAjouter = true;
         } else {
            boutonAjouter = config.editable.allowedOperations.create;
         }
      }

      boutonAnnuler = undefined ? false : boutonAnnuler;
      boutonSupprimer = undefined ? false : boutonSupprimer;
      boutonSave = undefined ? false : boutonSave;

      var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
      var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;

      var addrowAction = toolbarData.toolbarFind("selection-add-row");
      var saveAction = toolbarData.toolbarFind("save");
      //
      // Sélection du nombre d'enregistrement 
      // 
      toolbarGroup.unshift({
         type: "SELECT",
         action: "change-rows-per-page"
      });
      //
      // Ajout des boutons
      //
      if (boutonAjouter) {
         //
         // Retirer le bouton ajouter "selection-add-row" 
         //
         addrowAction.label = "Ajouter";
         addrowAction.icon = "fa fa-plus";
         addrowAction.iconBeforeLabel = true;
         addrowAction.hot = true;
      } else {
         toolbarGroupAction3.pop();
      }
      if (boutonSave) {
         saveAction.icon = "fa fa-table-arrow-down";
         saveAction.label = "Enregistrer la grille";
         saveAction.iconBeforeLabel = true;
         saveAction.hot = true;
         toolbarGroupAction2.pop();

      }
      //
      // Bouton Annuler modification
      //
      var modelBoutonAnnulerModif = {
         type: "BUTTON",
         name: "annuler-ligne",
         label: "Annuler",
         action: "selection-revert",
         icon: "fa fa-undo",
         iconBeforeLabel: true,
         hot: false
      };
      toolbarGroupAction3.push(modelBoutonAnnulerModif);
      //
      // Bouton save 
      //
      if (boutonSave) {
         toolbarGroupAction3.push(saveAction);
      }
      //
      // Bouton Supprimer
      //
      if (boutonSupprimer) {
         var modelBoutonSupprimer = {
            type: "BUTTON",
            name: "supprimer-ligne",
            label: "Supprimer",
            action: "selection-delete",
            icon: "fa fa-trash-o",
            iconBeforeLabel: true,
            hot: false
         };
         toolbarGroupAction3.push(modelBoutonSupprimer);
      }
      //
      // Ajout du mode skipReadonlyCells
      // 
      config.defaultGridViewOptions = config.defaultGridViewOptions || {};
      var skipReadonlyCells = {
         skipReadonlyCells: true,
      };
      $.extend(config.defaultGridViewOptions, skipReadonlyCells);
      //
      // retourne la config
      //
      config.toolbarData = toolbarData;
      return config;
   };

   //
   // configuration de la barre d'outils de la grid interactive.
   //   
   ig.configurerBarreOutilsBoutonsLecture = function (config) {
      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar      
      var toolbarGroup = toolbarData.toolbarFind("actions1").controls;

      /* indique si la grid on peut ajouter des données */

      var toolbarGroupAction3 = toolbarData.toolbarFind("actions3").controls;
      var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;
      //
      // Sélection du nombre d'enregistrement 
      // 
      toolbarGroup.unshift({
         type: "SELECT",
         action: "change-rows-per-page"
      });
      //
      // Suppression des boutons
      //      
      toolbarGroupAction3.pop();
      toolbarGroupAction2.shift();
      toolbarGroupAction2.pop();

      //
      // retourne la config
      //
      config.toolbarData = toolbarData;
      return config;
   };

   ig.initialiserToolbarFacetedSearch = function (config) {

      var toolbarData = $.apex.interactiveGrid.copyDefaultToolbar(); // copie la toolbar
      var toolbarGroupAction2 = toolbarData.toolbarFind("actions2").controls;
      var toolbarGroup = toolbarData.toolbarFind("actions1");

      toolbarData.toolbarRemove("actions2");

      //
      // Sélection du nombre d'enregistrement 
      // 
      toolbarGroup.controls.push({
         type: "SELECT",
         action: "change-rows-per-page"
      });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-columns-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-filter-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-sort-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      toolbarGroup.controls.push(
         {
            type: "BUTTON",
            action: "show-aggregate-dialog",
            iconBeforeLabel: true,
            hot: true
         });

      config.toolbarData = toolbarData;

      return config;

   };

   ig.assignerValeurJsChangeEvent = function (elementDeclancheur, ecraserValeur) {

      /* shq.ig.assignerValeurJsChangeEvent(this.triggeringElement); */

      // eslint-disable-next-line no-undef
      var valeur = elementDeclancheur.id === undefined ? null : $v2(elementDeclancheur.id);
      ecraserValeur = ecraserValeur === undefined ? false : ecraserValeur;

      switch (ecraserValeur) {
         case true:
            break;
         case false:
            // eslint-disable-next-line no-self-assign
            valeur = valeur;
            break;
         default:
            valeur = null;
      }
      return valeur;
   };

   /**
    * Initialisation de la grille interactive pour mémoriser la page et la selection.
    * @author Michel Lessard
    * @date 2020-12-01
    * @param 
    * @returns la fonction puiblique
    */
   ig.initialiserPageSelectionIg = (function () {

      var gInitialPages = {}; // map regionId -> {} map view -> init info
      var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;

      var urlParts = window.location.search.split(":"),
         resetPagination = urlParts[5] && urlParts[5].match(/RP/);

      // Move info from the session storage into gInitialPages structure so that
      // it can be used just once as the various widgets get initialized.
      function _setInitInfo(store, regionId, key) {
         var offset, count, info,
            sel = store.getItem(key + "LastSelection"),
            lastPage = store.getItem(key + "LastPage");

         // never trust session/local storage - validate!
         if (lastPage && lastPage.match(/\d+:\d+/)) {
            lastPage = lastPage.split(":");
            offset = parseInt(lastPage[0], 10);
            count = parseInt(lastPage[1], 10);
            info = { offset: offset, count: count };
            if (sel) {
               // not much validation of the selection that can be done
               info.sel = sel;
            }
            apex.util.getNestedObject(gInitialPages, regionId)[key] = info;
            apex.debug.message(C_LOG_DEBUG, '_setInitInfo:', info.offset, info.count);
         }
      }

      /*
       * At this point we don't know all the IG regions on the page because they 
       * haven't been inintialized yet. $(".a-IG") won't work yet!
       * But only care if info was put in sesson storage so use info from the keys
       * to get all the region ids.
       */
      var i, parts, len, store, regionId,
         igRegions = {};

      store = apex.storage.getScopedSessionStorage({ usePageId: true });
      len = store.length;

      for (i = 0; i < len; i++) {
         parts = store.key(i).split("."); // assume region id doesn't include "."!
         igRegions[parts[3]] = 1;
      }

      igRegions = Object.keys(igRegions);

      if (resetPagination) {
         // reset pagination for each of the possible views of each IG region
         igRegions.forEach(function (element) {
            regionId = element;
            store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId });
            store.removeItem("gridLastPage");
            store.removeItem("iconLastPage");
            store.removeItem("detailLastPage");
         });
         apex.debug.message(C_LOG_DEBUG, 'resetPagination');
      } else {
         // prepare to restore the pagination offset for each of the possible veiws of each IG region
         igRegions.forEach(function (element) {
            regionId = element;
            // return to remembered IG page
            // store the lastPage info for when the IG view widgets are initalized
            store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId });
            _setInitInfo(store, regionId, "grid");
            _setInitInfo(store, regionId, "icon");
            _setInitInfo(store, regionId, "detail");
            apex.debug.message(C_LOG_DEBUG, 'Preparation restauration page');
         });
      }

      /*
    * Step 1
    * When the page or selection changes remember it per view
    * Step 2
    * Store the information in browser session storage
    */
      ig.memoriserPageSelectionIg = function () {
         //
         // Bind les énements pour chaque IG.
         // 
         var igRegionsId = {};

         igRegionsId = $(".a-IG").map(function (index, element) { return (element.id); });

         igRegionsId.map(function (index, element) {

            var IgRegionId$ = '#'.concat(element);
            apex.debug.message(C_LOG_DEBUG, 'Bind event gridpagechange tablemodelviewpagechange id:', IgRegionId$);

            $(IgRegionId$).on("gridpagechange tablemodelviewpagechange", function (event, data) {
               var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
               var initInfo, sel,
                  ig$ = $(this),
                  regionId = this.id, // not exactly the region id but in the spirt of the regionId option of getScopedSessionStorage
                  store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId }),
                  viewId = ig$.interactiveGrid("getCurrentViewId");

               if (viewId.match(/icon|grid|detail/)) {
                  if (data.count === null) {
                     store.setItem(viewId + "LastPage", data.offset + ":0");
                  }
                  else {
                     store.setItem(viewId + "LastPage", data.offset + ":" + data.count);
                  }
                  // Also part of step 3 restore the selection
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId][viewId];
                  if (initInfo && initInfo.sel) {
                     sel = initInfo.sel;
                     ig$.interactiveGrid("setSelectedRecords", sel.split("|"));
                     delete initInfo.sel;
                  }
               }
            });

            apex.debug.message(C_LOG_DEBUG, 'Bind event interactivegridselectionchange id:', IgRegionId$);
            $(IgRegionId$).on("interactivegridselectionchange", function (event, data) {
               var initInfo, sel, model,
                  ig$ = $(this),
                  regionId = this.id, // not exactly the region id but...
                  store = apex.storage.getScopedSessionStorage({ usePageId: true, regionId: regionId }),
                  view = ig$.interactiveGrid("getCurrentView"),
                  viewId = view.internalIdentifier;

               if (viewId.match(/icon|grid/)) {
                  model = view.model;
                  var lastPage = store.getItem(viewId + "LastPage");
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId][viewId];
                  initInfo = initInfo === undefined ? {} : initInfo;
                  //
                  // Équivalent du P39_SELECTION_OVERRIDE mais pour la page 1
                  // 
                  if ($nvl(initInfo.sel === undefined ? false : initInfo.sel, false) && initInfo.offset === 0) {
                     sel = initInfo.sel;
                     lastPage = null;
                  } else {
                     sel = ig$.interactiveGrid("getSelectedRecords").map(function (r) { return model.getRecordId(r); }).join("|");
                  }
                  store.setItem(viewId + "LastSelection", sel);
                  if (lastPage === null) {
                     var nbRecPage = view.view$.grid("option", "rowsPerPage");
                     var dataEvent = { offset: 0, count: nbRecPage };
                     var IgRegionId$ = '#'.concat(regionId);
                     apex.event.trigger($(IgRegionId$), "gridpagechange", dataEvent);
                  }
                  apex.debug.message(C_LOG_DEBUG, "SAVED selection change: ", regionId, viewId, sel);
               }

            });
         });
      };

      /*
       * Step 3
       * Restore the IG page (row offset really) when IG view widgets are initalized.
       * See code above for how the session store info was gathered and made available for this step.
       */
      /*
       * The grid and tableModelView widgets just don't let you initialize them
       * with a starting offset. They always start at 0. This is a problem for
       * returning to a specific page. (See comments below on the first failed attempt that lead to this solution)
       * Extend the widgets in-place to allow setting an initial offset
       * Needs to happen after interactiveGrid and related widgets are loaded but before they are initalized
       *
       * Warning: using undocumented internal properties of the grid and tableModelView widgets.
       */

      $(function () {

         $.widget("apex.grid", $.apex.grid, {
            refresh: function (focus) {
               var regionId, initInfo;
               // if this grid is in an IG view
               if (this.element.hasClass("a-IG-gridView")) {
                  regionId = this.element.closest(".a-IG")[0].id; // id of IG region
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId].grid;

                  if (initInfo && initInfo.offset) {

                     this.pageOffset = initInfo.offset;
                     delete initInfo.offset;
                     if (this.pageOffset > 0) {
                        // Workaround a failed assumption in the model that the first request
                        // will be for offset 0.
                        // Warning using undocumented member _data.
                        var igLenght = this.model._data.length === 0 ? 1 : this.model._data.length;
                        this.model._data.length = 1;
                        this.model._data.length = igLenght;
                     }
                     apex.debug.message(C_LOG_DEBUG, "RESTORE page offset", regionId, "grid", this.pageOffset, this.pageSize, "Sélection", initInfo.sel);
                  }
               }

               this._super(focus);
            }
         });
         $.widget("apex.tableModelView", $.apex.tableModelView, {
            refresh: function (focus) {
               var regionId, initInfo, viewId, key;

               // table model view is used for both icon view and detail view so figure out which one this instance is
               if (this.element.hasClass("a-IG-iconView")) {
                  viewId = "icon";
               } else if (this.element.hasClass("a-IG-detailView")) {
                  viewId = "detail";
               }
               if (viewId) {
                  key = viewId;
                  regionId = this.element.closest(".a-IG")[0].id; // id of IG region
                  initInfo = gInitialPages[regionId] && gInitialPages[regionId][key];
                  if (initInfo && initInfo.offset) {
                     this.pageOffset = initInfo.offset;
                     delete initInfo.offset;
                     if (this.pageOffset > 0) {
                        // Workaround a failed assumption in the model that the first request
                        // will be for offset 0.
                        // Warning using undocumented member _data.
                        this.model._data.length = 1;
                     }
                  }
               }
               this._super(focus);
            }
         });
      });

      // return app namespace
      return {
         memoriserPageSelectionIg: ig.memoriserPageSelectionIg
      };
   });

   ig.inactiverEnteteColonne = function (config) {
      config.defaultGridColumnOptions = config.defaultGridColumnOptions || {};
      // 
      // Désactive la sélection de l'entête de colonne 
      //       
      var noHeaderColonne = {
         noHeaderActivate: true,
      };

      $.extend(config.defaultGridColumnOptions, noHeaderColonne);
      return config;
   };
   /*
   /   Fonction qui permet de fixer le collapsable d'un groupement 
   */
   ig.DeactivercollapsableControlBreak = function (config) {
      config.defaultGridViewOptions = {
         collapsibleControlBreaks: false
      };

      return config;
   };
   /*
   /  Fonction qui permet d'afficher des minutes en heures formatté 99:99
   */
   ig.appliquerFormatHeure = function (staticId) {

      function padTo2Digits(num) {
         return num.toString().padStart(2, '0');
      }

      apex.item.create(staticId, {
         displayValueFor: function (value) {

            const totalMinutes = value;
            const minutes = totalMinutes % 60;
            const hours = Math.floor(totalMinutes / 60);

            return `${padTo2Digits(hours)}:${padTo2Digits(minutes)}`;
         }
      });
   };
})(shq.ig, shq, apex.theme42, apex.jQuery);
/* eslint-disable no-unused-vars */
/* global apex */

/* 

-  Dans l'option de la page Execute when Page Loads 
 
   shq.ig.action.asynMenugrilleShq ("static id de la grid" , "Code de menu");
   
   Exemple:
   shq.ig.action.asynMenugrilleShq ('repertoireCode','GPR_CLIENT')
     
*/


var shq = shq || {};
shq.ig = shq.ig || {};
shq.ig.action = {};

(function (actionGridMenu, apex, $) {
   "use strict";

   var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
   var C_DIESE = '#';

   actionGridMenu.initialiserColoneMenu = function (options) {

      options.defaultGridColumnOptions = options.defaultGridColumnOptions || {};
      options.heading = options.heading || {};
      options.features = options.features || {};

      var optionColone = {
         seq: 1,
         headingAlignment: "center",
         noStretch: true,
         noHeaderActivate: true,
         width: "40px",
         canHide: false,
         heading: "",
         columnCssClasses: "has-button",
         alignment: "center",
         resizeColumns: false,
         usedAsRowHeader: false,
         canSort: false
      };
      var optionHeading = {
         label: "Menu enregistrement"
      };

      var optionFeatures = {
         canHide: false
      };

      $.extend(options.defaultGridColumnOptions, optionColone);
      $.extend(options.heading, optionHeading);
      $.extend(options.features, optionFeatures);

      apex.debug.message(C_LOG_DEBUG, 'initialiserColoneMenu', optionColone);
      apex.debug.message(C_LOG_DEBUG, 'initialiserColoneMenu', optionHeading);
      apex.debug.message(C_LOG_DEBUG, 'initialiserColoneMenu', optionFeatures);

      return options;
   };

   var _creerMarkupGrilleShqMenu = function (igMenuActionShq) {

      var divDataMenu = $("<div>");
      divDataMenu.attr("id", igMenuActionShq);
      divDataMenu.css("display", "none");
      divDataMenu.attr("tabindex", "-1");
      divDataMenu.attr("role", "menu");

      var divBody = $("body");
      // divBody.append(divDataMenu);
   };

   var _initialiserGrid = function (pRegionStaticId) {
      // Interactive Grid            
      var grid = apex.region(pRegionStaticId).call('getViews', 'grid');
      var gridObject = {
         grid: grid,
         record: null,
         fields: grid.model.getOption("fields"),
         recordId: null
      };
      return gridObject;
   };

   var _obtenirValeurColonesIg = function (gridObject) {
      var coloneGrids = [];

      $.each(gridObject.fields, function (index, val) {
         var coloneGrid = {
            nomColone: val.property,
            valeurColone: gridObject.grid.model.getRecordValue(gridObject.recordId, val.property)
         };
         coloneGrids.push(coloneGrid);
      });
      apex.debug.message(C_LOG_DEBUG, '_obtenirValeurColonesIg', coloneGrids);
   };

   actionGridMenu.asynMenugrilleShq = function (pRegionStaticId, pGridActionCode) {

      var C_IG_ROW_ACTION = '_ig_row_actions_menu';

      var igMenuActionShq = pRegionStaticId + "_ig_row_actions_menu",
         $igMenuActionShq = "#" + igMenuActionShq,
         $pRegionStaticId = '#'.concat(pRegionStaticId),
         igBody = '.a-IG-body';

      $($pRegionStaticId).on('click', '.js-menuButton', function (event) {
         //
         // Pas compatible ie
         // var targetMenuButton = event.target.closest("button");
         //
         var targetMenuButton = $(event.target).parent();
         var record = gridObject.grid.getContextRecord(targetMenuButton)[0];

         gridObject.record = record;
         //
         // Pas compatible ie
         //gridObject.recordId = $(targetMenuButton).closest('tr').data("id");
         // 
         gridObject.recordId = $(targetMenuButton).parents("tr:first").attr("data-id");
         // Logging
         apex.debug.message(C_LOG_DEBUG, 'asynMenugrilleShq - event.target', targetMenuButton);

      });

      var gridObject = _initialiserGrid(pRegionStaticId);


      //
      //      Ce code ne fonctionne pas pour une grille en maitre-detail...la grid detail le editable est à faux.
      //      Moi et Maxime on est en réflexion....
      //         
      //      if (gridObject.grid.model.getOption("editable") === false ) {
      //            _creerMarkupGrilleShqMenu(igMenuActionShq);
      //         $($igMenuActionShq).menu({
      //            items: [{ id: 'vide' }],
      //            create: function (event, ui) {
      //               apex.debug.message(C_LOG_DEBUG, "_initialiserGrid - Create menu", igMenuActionShq);
      //            }
      //         });
      //      }

      $($igMenuActionShq).menu(
         {
            asyncFetchMenu: function (menu, callback) {

               var processGrilleAction = 'APX - Grille action';

               console.log(gridObject.recordId);

               _obtenirValeurColonesIg(gridObject);

               if (!gridObject.grid.model.getRecordMetadata(gridObject.recordId).inserted) {
                  var promise = apex.server.process(processGrilleAction, {
                     x01: pGridActionCode,
                     x02: gridObject.recordId
                  });

                  apex.debug.message(C_LOG_DEBUG, "asyncFetchMenu", pGridActionCode, gridObject.recordId);

                  promise.done(function (data) {
                     // 
                     // Suppression des items de menu SHQ pour s'assurer d'avoir les items de menu correspondant à la ligne
                     // 
                     var nombreitemsMenu = menu.items.length;

                     menu.items.slice().reverse().forEach(function (currentValue, index, arr) {
                        if (currentValue.id && currentValue.id.indexOf('shq_') === 0) {
                           menu.items.splice(arr.length - 1 - index, 1);
                        }
                     });
                     // 
                     // Ajour des items de menu SHQ de la ligne en cours
                     // 
                     data.items.slice().reverse().forEach(function (currentValue, index, array) {
                        switch (currentValue.attr.positionType) {
                           case 'TOP':
                              menu.items.unshift(currentValue.item);
                              break;
                           default:
                        }
                     });

                     data.items.forEach(function (currentValue, index, array) {
                        switch (currentValue.attr.positionType) {
                           case 'BOTTOM':
                              menu.items.push(currentValue.item);
                              break;
                           default:
                        }
                     });

                     // 
                     apex.debug.message(C_LOG_DEBUG, "menu", menu);
                     //
                     // Retour du callback
                     //
                     callback();
                  }).fail(function (jqXHR, textStatus) {
                     // handle error         
                     apex.debug.error('Erreur  dans la function _obtenirGrilleShqMen Callback: ' + textStatus);
                     callback(false);
                  }).always(function () {
                     // code that needs to run for both success and failure cases
                  });
               }
               else {
                  //
                  // Simulation du code asynchrone 
                  // Pour un insertion d'un nouvel enregistrement on ne désire pas faire un hit au serveur.
                  // 
                  setTimeout(function () { callback(); }, 0);
               }
            }
         }
      );
   };

   actionGridMenu.gridMenuAction = function () {
      
      const C_IG_ROW_ACTION = '_ig_row_actions_menu';
      const igBody = '.a-IG-body';

      $('.t-Region[data-menu-grid]').each(function (index, element) {

         let gridMenu = {};
         gridMenu.staticId = element.id;
         gridMenu.$staticId = C_DIESE.concat(gridMenu.staticId);
         gridMenu.idMenuActionshq = gridMenu.staticId.concat(C_IG_ROW_ACTION);
         gridMenu.$idMenuActionshq = C_DIESE.concat(gridMenu.idMenuActionshq);
         gridMenu.actionCode = $(element).data("menu-grid");
          
         let gridObject = _initialiserGrid(gridMenu.staticId);

         $(gridMenu.$staticId).on('click', '.js-menuButton', function (event) {
            //
            // Pas compatible ie
            // var targetMenuButton = event.target.closest("button");
            //
            
            var targetMenuButton = $(event.target).parent();
            var record = gridObject.grid.getContextRecord(targetMenuButton)[0];
            
            gridObject.record = record;
            //
            // Pas compatible ie
            gridObject.recordId = $(targetMenuButton).closest('tr').data("id");
            // 
            //gridObject.recordId = $(targetMenuButton).parents("tr:first").attr("data-id");
            // Logging
            apex.debug.message(C_LOG_DEBUG, 'asynMenugrilleShq - event.target', targetMenuButton);
         });

         $(gridMenu.$idMenuActionshq).menu(
            {
               asyncFetchMenu: function (menu, callback) {
                  
                  var processGrilleAction = 'APX - Grille action';
   
                  console.log(gridObject.recordId);
   
                  _obtenirValeurColonesIg(gridObject);
   
                  if (!gridObject.grid.model.getRecordMetadata(gridObject.recordId).inserted) {
                     var promise = apex.server.process(processGrilleAction, {
                        x01: gridMenu.actionCode,
                        x02: gridObject.recordId
                     });
   
                     apex.debug.message(C_LOG_DEBUG, "asyncFetchMenu", gridMenu.actionCode, gridObject.recordId);
   
                     promise.done(function (data) {
                        // 
                        // Suppression des items de menu SHQ pour s'assurer d'avoir les items de menu correspondant à la ligne
                        // 
                        var nombreitemsMenu = menu.items.length;
   
                        menu.items.slice().reverse().forEach(function (currentValue, index, arr) {
                           if (currentValue.id && currentValue.id.indexOf('shq_') === 0) {
                              menu.items.splice(arr.length - 1 - index, 1);
                           }
                        });
                        // 
                        // Ajour des items de menu SHQ de la ligne en cours
                        // 
                        data.items.slice().reverse().forEach(function (currentValue, index, array) {
                           switch (currentValue.attr.positionType) {
                              case 'TOP':
                                 menu.items.unshift(currentValue.item);
                                 break;
                              default:
                           }
                        });
   
                        data.items.forEach(function (currentValue, index, array) {
                           switch (currentValue.attr.positionType) {
                              case 'BOTTOM':
                                 menu.items.push(currentValue.item);
                                 break;
                              default:
                           }
                        });
   
                        // 
                        apex.debug.message(C_LOG_DEBUG, "menu", menu);
                        //
                        // Retour du callback
                        //
                        callback();
                     }).fail(function (jqXHR, textStatus) {
                        // handle error         
                        apex.debug.error('Erreur  dans la function _obtenirGrilleShqMen Callback: ' + textStatus);
                        callback(false);
                     }).always(function () {
                        // code that needs to run for both success and failure cases
                     });
                  }
                  else {
                     //
                     // Simulation du code asynchrone 
                     // Pour un insertion d'un nouvel enregistrement on ne désire pas faire un hit au serveur.
                     // 
                     setTimeout(function () { callback(); }, 0);
                  }
               }
            }
         );         
      });

      


   


      //
      //      Ce code ne fonctionne pas pour une grille en maitre-detail...la grid detail le editable est à faux.
      //      Moi et Maxime on est en réflexion....
      //         
      //      if (gridObject.grid.model.getOption("editable") === false ) {
      //            _creerMarkupGrilleShqMenu(igMenuActionShq);
      //         $($igMenuActionShq).menu({
      //            items: [{ id: 'vide' }],
      //            create: function (event, ui) {
      //               apex.debug.message(C_LOG_DEBUG, "_initialiserGrid - Create menu", igMenuActionShq);
      //            }
      //         });
      //      }

      
   };
})(shq.ig.action, apex, apex.jQuery);
/* eslint-disable no-unused-vars */
/* global apex */
/* 

-  Dans l'option de la page Execute when Page Loads 
   
   Exemple:
	   
*/
var shq = shq || {};
shq.ig = shq.ig || {};
shq.ig.navgt = {};

(function (igNavgt, apex, $) {
	"use strict";


	var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
	var diese = '#';

	var ig = $('.shq-navgt-ig');
	var $id = $(diese.concat(ig.attr('id')));


	$id.on("gridpagechange", function (event, data) {
		apex.debug.info('__gridpagechange');
		shq.ig.navgt.enregistrerDataIg();

	});

	igNavgt.enregistrerDataIg = function () {

		var selRecords;
		var selRecordsJSON;
		var ig = $('.shq-navgt-ig');
		var PROCESS_NAME = 'APX - Enregistrer navigation';
		var gridView;
		var model;
		var seq;
		var current_seq;

		ig.each(function (index, element) {
			if (element.hasAttribute('data-nvgt-pkeys')) {

				selRecords = {
					"rows": []
				};
				var keys = {

				};
				var id = element.id;
				apex.debug.info('__id__'.concat(id));
				var $id = $(diese.concat(id));
				var igKeysArr = $id.attr('data-nvgt-pkeys').split(',');


				var igkeysValue = {};
				var igKeysTitle;
				var gridName = $id.attr('data-nvgt-gridkey');


				if (element.hasAttribute('data-nvgt-title')) {
					igKeysTitle = $id.attr('data-nvgt-title');
				}

				gridView = apex.region(id).widget().interactiveGrid("getViews").grid;


				model = gridView.model;
				seq = 0;

				model.forEach(function (element) {
					igkeysValue = {};
					for (var k = 0; k < igKeysArr.length; k++)
						igkeysValue[igKeysArr[k]] = model.getValue(element, igKeysArr[k]);

					var igTitle = igKeysTitle !== undefined ? model.getValue(element, igKeysTitle) : "";

					seq++;

					selRecords.rows.push({
						"seq": seq,
						'keys': igkeysValue,
						'title': igTitle
					});
				});

				selRecordsJSON = JSON.stringify(selRecords);

				var promise = apex.server.process(PROCESS_NAME, {
					x01: selRecordsJSON,
					x02: gridName,
					x03: igKeysArr.join(':')
				}, {
					success: function (pData) {
						apex.debug.info('__success__'.concat(PROCESS_NAME));						
					}
				});

			}

		});

	};



})(shq.ig.navgt, apex, apex.jQuery);
/* global apex */

//const { validate } = require("json-schema");

var shq = shq || {};
shq.ig_selection = {};

(function (ig_selection, shq, ut, $) {
    "use strict";
    var diese = '#';
    var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;

    ig_selection.assignerItemsIgSelectionne = function (colonneClef, collectionApex, data, modelIg) {


        var i, elements = [];
        var value;
        var id = data.model.getOption("regionStaticId");
        var view = apex.region(id).call("getCurrentView");


        if (view.singleRowMode) {
            return;
        }

        for (i = 0; i < data.selectedRecords.length; i++) {
            value = modelIg.getValue(data.selectedRecords[i], colonneClef);
            if (elements.indexOf(value)) {
                elements.push(value);
            }
        }

        var result = apex.server.process("ENREGISTRER_SELECTION_IG", {
            f01: elements,
            x01: collectionApex
        });

        apex.message.clearErrors();
        result.done(function (data) {
            var message = apex.lang.formatMessage('APEX.GV.SELECTION_COUNT',elements.length);
            apex.debug.info(message);
        }).fail(function (jqXHR, textStatus, errorThrown) {
            var message = apex.lang.getMessage('SHQ.ERREUR.SELECTION_ENREGISTREMENT');
            
            apex.message.showErrors([
                {
                    type: "error",
                    location: "page",
                    message: message,
                    unsafe: false
                }
            ]);
        });
    };

    ig_selection.enregistrementSelectione = function (data) {

        var id = data.model.getOption("regionStaticId");
        var view = apex.region(id).call("getCurrentView");
        
        var selectionne = false;
        

        if (view.singleRowMode) {
            return;
        }    

        /*
        if (view.view$.grid("inEditMode") && nbRecordSelected > 0) {
            return;
        }
        */

        var nbRecordSelected = data.selectedRecords === undefined ? 0 : data.selectedRecords.length;
        selectionne = nbRecordSelected === 0 ? false : true;        
        
        return selectionne;
        
    };

})(shq.ig_selection, shq, apex.theme42, apex.jQuery);
/* global apex */
/* global moment */
var shq = shq || {};
shq.item = {};

(function (item, shq, ut, $) {
   "use strict";
   //
   var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
   var diese = '#';
   //
   // Utiliser cette fonction à la place de repeat car pas supporté dans IE...c'est vraiment un cancer celui-là
   //
   function repeatStringNumTimes(string, times) {
      var repeatedString = "";
      while (times > 0) {
         repeatedString += string;
         times--;
      }
      return repeatedString;
   }

   item.appliquerMasque = function () {
      shq.item.appliquerMasqueTelephone();
      shq.item.appliquerMasqueCourriel();
      shq.item.appliquerMasqueDate();
      shq.item.appliquerMasqueHeure();
      shq.item.appliquerMasqueCodePostal();
      shq.item.appliquerMasqueCodeDebutAlpha();
      shq.item.appliquerMasqueCodeAlphaNum();
      shq.item.appliquerMasqueCodeNum();
      shq.item.appliquerMasqueCodeAlpha();
      shq.item.appliquerMasqueTvq();
      shq.item.appliquerMasqueTps();
      shq.item.appliquerMasqueMontantAucuneDecimal();
      shq.item.appliquerMasqueMontantDeuxDecimal();
      shq.item.appliquerMasquePourcentage();
      shq.item.appliquerMasquePourcentageSansSigne();
      shq.item.appliquerMasqueNumeriqueDeuxDecimales();
      shq.item.appliquerMasqueNumeriqueSansDecimal();
   };
   //
   //
   //
   item.validerDate = function (dateItem) {
      var item$ = $(diese.concat(dateItem));
      var l_dateFormat = 'YYYY-MM-DD';
      var l_dateValue = item$.val();
      // Valide la date 
      return moment(l_dateValue, l_dateFormat, true).isValid();
   };
   //
   // Applique le masque heure 
   //
   item.appliquerMasqueHeure = function (listeItems) {

      var l_item;

      var DEBUTAM = 'DAM',
         DEBUTPM = 'DPM',
         FINAM = 'FAM',
         FINPM = 'FPM',
         HEUREPLUSUNEJOURNEE = 'HPUJ',
         HEUREPLUSUNEJOURNEENEGATIVE = 'HPUJNEG',
         HEUREPLUSUNEJOURNEEACTIVITE = 'HAUJ',
         HEUREPLUSUNEJOURNEENEGATIVEACTIVITE = 'HAUJNEG',
         NEGATIVE = 'HNEG';



      var completerHeureSaisie = function (heure) {
         //
         //  Formatteur la partir heure, "padder" à gauche avec un zéro
         // 
         apex.debug.message(C_LOG_DEBUG, 'Fomatter Heure');

         var ArrayHeure = heure.split(':');

         if (ArrayHeure.length === 2) {

            apex.debug.message(C_LOG_DEBUG, 'Entre dans le if length 2');

            if ((/[1-2]/).test(ArrayHeure[0].length) && ArrayHeure[1].length === 2) {

               apex.debug.message(C_LOG_DEBUG, 'Entre dans le if mettre 0');

               var valeurHeure = ArrayHeure[0];

               var partieHeure;

               switch (valeurHeure.length) {
                  case 1:
                     partieHeure = '0';
                     break;

                  case 2:
                     if (/^-/.test(valeurHeure)) {
                        partieHeure = '-0';
                     } else if (/^0/.test(valeurHeure)) {
                        partieHeure = '0';
                     } else {
                        partieHeure = valeurHeure;
                     }
                     break;
                  default:
                     partieHeure = valeurHeure;
               }

               var valeurMinutes = ArrayHeure[1];

               valeurHeure = valeurHeure.replace(/^(-0|0|-)/, '');
               partieHeure = valeurHeure.length === 1 ? partieHeure + valeurHeure : partieHeure;
               heure = partieHeure.concat(':' + valeurMinutes);

               apex.debug.message(C_LOG_DEBUG, 'valeurHeure heureComplete : ' + heure);
            }
         }

         return heure;
      };

      var shqHeureTranslation = {

         "A": { pattern: /[0-2]/, optional: true },
         "B": { pattern: /[0-9]/, optional: false },
         "C": { pattern: /[0-5]/, optional: false },
         "D": { pattern: /[0-9]/, optional: false },
         "E": { pattern: /[0-3]/, optional: false },
         "F": { pattern: /[0-2]/, optional: false },
         "G": { pattern: /[1-9]/, optional: false },
         "H": { pattern: /[0-1]/, optional: false },
         "I": { pattern: /[2-9]/, optional: false },
         "J": { pattern: /[0-9]/, optional: true },
         "K": { pattern: /[7-9]/, optional: false },
         "M": { pattern: /-/, optional: true },
         "N": { pattern: /[0-3]/, optional: true },
         "O": { pattern: /[0-9]/, optional: true }
      };

      var SPMaskBehavior = function (val) {
         apex.debug.message(C_LOG_DEBUG, 'SPMaskBehavior', val);
         return val.replace(/\D/g, '')[0] === '2' ? 'AE:CD' : 'AB:CD';
      },
         SPMaskBehaviorNegative = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'SPMaskBehaviorNegative', val);
            return val.replace(/\D/g, '')[0] === '2' ? 'MAN:CD' : 'MAO:CD';
         },
         spOptions = {
            onKeyPress: function (val, e, field, options) {
               field.mask(SPMaskBehavior.apply({}, arguments), options);
               var valArray = val.split(":");
               if (valArray.length == 2) {
                  field.val(completerHeureSaisie(val));
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         spOptionsNegative = {
            onKeyPress: function (val, e, field, options) {
               field.mask(SPMaskBehaviorNegative.apply({}, arguments), options);
               var valArray = val.split(":");
               if (valArray.length == 2) {
                  field.val(completerHeureSaisie(val));
               }
            },
            onChange: function (value, e) {
               e.target.value = value.replace(/(?!^)-/g, '')
                  .replace(/^(-[:])/, '-')
                  .replace(/(\d+\:*)\:(\d{2})$/, "$1:$2");
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPlusUneJournee = function (val) {
            var mask = 'JJ:CD';
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJournee', val);
            return mask;
         },
         spOptionsPlusUneJournee = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJournee.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPlusUneJourneeNegative = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJourneeNegative', val);
            var mask = 'MJJ:CD';
            return mask;

         },
         spOptionsPlusUneJourneeNegative = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJourneeNegative.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            onChange: function (value, e) {
               e.target.value = value.replace(/(?!^)-/g, '')
                  .replace(/^(-[:])/, '-')
                  .replace(/(\d+\:*)\:(\d{2})$/, "$1:$2");
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         /* 3 positions */
         shqMaskPlusUneJourneeActivite = function (val) {
            var mask = 'JJJ:CD';
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJourneeActivite', val);
            return mask;
         },
         spOptionsPlusUneJourneeActivite = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJourneeActivite.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPlusUneJourneeNegativeActivite = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPlusUneJourneeNegativeActivite', val);
            var mask = 'MJJJ:CD';
            return mask;

         },
         spOptionsPlusUneJourneeNegativeActivite = {
            onKeyPress: function (val, e, field, options) {
               //
               // Applique le masque de saisie
               // 
               field.mask(shqMaskPlusUneJourneeNegativeActivite.apply({}, arguments), options);
               var valArray = val.split(":");

               switch (valArray.length) {
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            onChange: function (value, e) {
               e.target.value = value.replace(/(?!^)-/g, '')
                  .replace(/^(-[:])/, '-')
                  .replace(/(\d+\:*)\:(\d{2})$/, "$1:$2");
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         /* Fin 3 positions */
         shqMaskAm = function (val) {

            apex.debug.message(C_LOG_DEBUG, 'shqMaskDebutAm', val);
            var valeur = val.replace(/\D/g, '').split(":")[0];
            var mask;

            if (/^13/g.test(valeur)) {
               mask = 'H3:HC';
            } else if (/^1/.test(valeur)) {
               mask = 'HE:CD';
            } else if (/^0|[^[0-1]]/.test(valeur)) {
               mask = 'AK:CD';
            } else {
               mask = 'AD:CD';
            }
            return mask;
         },
         spOptionsShqHeureAm = {
            onKeyPress: function (val, e, field, options) {
               //
               // Appliquer le masque de saisie
               //
               field.mask(shqMaskAm.apply({}, arguments), options);
               // 
               // Valider la saisie DEBUTAM
               // 
               var valArray = val.split(":");


               switch (valArray.length) {
                  case 1:
                     var heureAm = valArray.slice(0, 2).join("");
                     apex.debug.message(C_LOG_DEBUG, 'heureDebutAm', heureAm);
                     if (/^[7-9]/.test(heureAm)) {
                        field.val(completerHeureSaisie(val));
                     } else if (!(/^[0-1]/.test(heureAm))) {
                        field.val("");
                     }
                     break;
                  case 2:
                     field.val(completerHeureSaisie(val));
                     break;
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         },
         shqMaskPm = function (val) {
            apex.debug.message(C_LOG_DEBUG, 'shqMaskPm', val);
            var valeur = val.replace(/\D/g, '').split("");
            var heure;
            var mask;

            switch (valeur.length) {
               case 1:
                  heure = parseInt(valeur.slice(0, 1).join(""));
                  break;
               case 2:
                  heure = parseInt(valeur.slice(0, 2).join(""));
                  break;

            }
            switch (true) {
               case heure === 1:
                  mask = 'GI:CD';
                  break;
               case heure === 2 || heure > 19:
                  mask = 'FE:CD';
                  break;
               default:
                  mask = 'FD:CD';
            }
            return mask;
         },
         spOptionsShqHeurePm = {
            onKeyPress: function (val, e, field, options) {
               //
               // Appliquer le masque de saisie
               //
               field.mask(shqMaskPm.apply({}, arguments), options);
               // 
               // Valider la saisie DEBUTAM
               // 

               var valArray = val.split(":");
               var PATTERNHEUREPM = /^([1][2-9]|2[0-3])$/;

               switch (valArray.length) {
                  case 1:
                     var heurePm = valArray.slice(0, 2).join("");
                     apex.debug.message(C_LOG_DEBUG, 'heurePm', heurePm);
                     if (!PATTERNHEUREPM.test(heurePm) && heurePm.length === 2) {
                        field.val("");
                     }
                     break;
                  case 2:
                     field.val(completerHeureSaisie(val));
               }
            },
            translation: shqHeureTranslation,
            recursive: true
         };

      listeItems = listeItems === undefined ? '' : listeItems;

      if (listeItems.length === 0) {
         $('.shq-heure').each(function (i, val) {

            l_item = val.id;
            var item$ = $(diese.concat(l_item));
            //
            // Obtenir le data attribut sur l'item
            // 
            var indicateurHeure = $(item$).attr('data-heure');
            //
            //  Application du masque
            //     
            switch (indicateurHeure) {
               case DEBUTAM:
                  $(diese.concat(val.id)).mask(shqMaskAm, spOptionsShqHeureAm);
                  break;
               case FINAM:
                  $(diese.concat(val.id)).mask(shqMaskAm, spOptionsShqHeureAm);
                  break;
               case DEBUTPM:
                  $(diese.concat(val.id)).mask(shqMaskPm, spOptionsShqHeurePm);
                  break;
               case FINPM:
                  $(diese.concat(val.id)).mask(shqMaskPm, spOptionsShqHeurePm);
                  break;
               case HEUREPLUSUNEJOURNEE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJournee, spOptionsPlusUneJournee);
                  break;
               case HEUREPLUSUNEJOURNEENEGATIVE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJourneeNegative, spOptionsPlusUneJourneeNegative);
                  break;
               case HEUREPLUSUNEJOURNEEACTIVITE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJourneeActivite, spOptionsPlusUneJourneeActivite);
                  break;
               case HEUREPLUSUNEJOURNEENEGATIVEACTIVITE:
                  $(diese.concat(val.id)).mask(shqMaskPlusUneJourneeNegativeActivite, spOptionsPlusUneJourneeNegativeActivite);
                  break;
               case NEGATIVE:
                  $(diese.concat(val.id)).mask(SPMaskBehaviorNegative, spOptionsNegative);
                  break;

               default:
                  $(diese.concat(val.id)).mask(SPMaskBehavior, spOptions);
            }

            //
            // Application de la validation generale d'une heure de saisie HTML5
            // 
            var l_regexp;
            if (indicateurHeure == HEUREPLUSUNEJOURNEE) {
               l_regexp = new RegExp(/^([0-9][0-9]):[0-5][0-9]$/);
            } else if (indicateurHeure === HEUREPLUSUNEJOURNEENEGATIVE) {
               l_regexp = new RegExp(/^-?([0-9][0-9]):[0-5][0-9]$/);
            } else if (indicateurHeure == HEUREPLUSUNEJOURNEEACTIVITE) {
               l_regexp = new RegExp(/^([0-9]?[0-9][0-9]):[0-5][0-9]$/);
            } else if (indicateurHeure === NEGATIVE) {
               l_regexp = new RegExp(/^-?([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/);
            } else if (indicateurHeure === HEUREPLUSUNEJOURNEENEGATIVEACTIVITE) {
               l_regexp = new RegExp(/^-?([0-9]?[0-9][0-9]):[0-5][0-9]$/);
            } else {
               l_regexp = new RegExp(/^([0-9]|0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]$/);
            }

            var l_message = apex.lang.formatMessage("SHQ.ITEM.HEURE_INVALID");

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurTel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurTel).mask(l_maskHeure);
         });
      }
   };
   //
   // Applique le masque code postal
   //
   item.appliquerMasqueCodePostal = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      var l_maskCodePostal = "S0S 0S0";
      var optionsMask = {
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-postal').each(function (i, val) {
            $(diese.concat(val.id)).mask(l_maskCodePostal, optionsMask);
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/[A-Za-z][0-9][A-Za-z] [0-9][A-Za-z][0-9]/);
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_POSTAL_INVALID");

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurTel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurTel).mask(l_maskCodePostal);
         });
      }
   };
   //
   // Applique le masque date
   //
   item.appliquerMasqueDate = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      var l_maskDate = "0000-00-00";

      if (listeItems.length === 0) {
         $('.shq-date').each(function (i, val) {
            $(diese.concat(val.id)).mask(l_maskDate);
            var l_dateFormat = 'AAAA-MM-JJ';
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_itemDateFormat = item$.attr('placeholder') ? item$.attr('placeholder') : l_dateFormat;
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/(?:19|20)[0-9]{2}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-9])|(?:(?!02)(?:0[1-9]|1[0-2])-(?:30))|(?:(?:0[13578]|1[02])-31))/);
            var l_message = apex.lang.formatMessage("APEX.DATEPICKER_VALUE_INVALID", l_itemDateFormat).replace('#LABEL#', itemLabel$.text());

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurDate = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurDate).mask(l_maskDate);
         });
      }
   };
   //
   // Applique le masque téléphonique 
   //
   item.appliquerMasqueTelephone = function (listeItems) {
      var l_mask_phone = '000 000-0000';
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-telephone').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/\d{3} \d{3}[\-]\d{4}/);
            var l_message = apex.lang.formatMessage("SHQ.ITEM.PHONENUMBER_INVALID", l_mask_phone).replace('#LABEL#', itemLabel$.text());

            item$.mask(l_mask_phone);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurTel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurTel).mask(l_mask_phone);
         });
      }
   };
   //
   // Applique le masque pour la saisie d'un courriel  
   // 
   item.appliquerMasqueCourriel = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-courriel').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var itemLabel$ = $(diese.concat(l_item.concat('_LABEL')));
            var l_regexp = new RegExp(/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/);

            item$.mask('A', {
               translation: {
                  'A': { pattern: /[\w@\-.+]/, recursive: true }
               }
            });

            var l_message = apex.lang.formatMessage("SHQ.ITEM.COURRIEL_INVALID").replace('#LABEL#', itemLabel$.text());
            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteurCourriel = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurCourriel).mask('A', {
               translation: {
                  'A': { pattern: /[\w@\-.+]/, recursive: true }
               }
            });
         });
      }
   };
   //
   // Appliquer le masque pour la saisie Aucune décimal
   // 
   /*
     Options format monétaire
  */
   var MoneyOpts = {
      reverse: true,
      maxlength: false,
      placeholder: '0,00',
      onKeyPress: function (v, ev, curField, opts) {
         var mask = curField.data('mask').mask;
         var decimalSep = (/0(.)00/gi).exec(mask)[1] || ',';
         if (curField.data('mask-isZero') && curField.data('mask-keycode') == 8)
            $(curField).val('');
         else if (v) {
            // remove previously added stuff at start of string
            v = v.replace(new RegExp('^0*\\' + decimalSep + '?0*'), ''); //v = v.replace(/^0*,?0*/, '');
            v = v.length == 0 ? '0' + decimalSep + '00' : (v.length == 1 ? '0' + decimalSep + '0' + v : (v.length == 2 ? '0' + decimalSep + v : v));
            $(curField).val(v).data('mask-isZero', (v == '0' + decimalSep + '00'));
         }
      }
   };

   item.appliquerMasqueMontantAucuneDecimal = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-montant-aucune-decimal').each(function (i, val) {
            $(diese.concat(val.id)).mask(" 00 000 000", { reverse: true });
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurMontant = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurMontant).mask(" 00 000 000", { reverse: true });
         });
      }
   };
   //
   // Appliquer le masque pour la saisie deux décimales
   // 
   item.appliquerMasqueMontantDeuxDecimal = function (listeItems) {

      /* 
      * à compléter et valider pour les nombre ngatif 
      * 
     

      var sOptions = {
         reverse: true,
         translation: {
            'S': {
               pattern: /-|\d/,
               optional: true,
               recursive: true
            }
         },
         onChange: function (value, e) {

            var target = e.target,
               position = target.selectionStart; // Capture initial position

            target.value = value.replace(/(?!^)-/g, '').replace(/^,/, '').replace(/^-(,| )/, '-');
            target.selectionEnd = position; // Set the cursor back to the initial position.
         }
      };
 */
      // Mascara para Dinheiro e Decimais com Prefixo e Sinal negativo
      // Font base: https://github.com/igorescobar/jQuery-Mask-Plugin/issues/670 point to http://jsfiddle.net/c6qj0e3u/15/
      // Edited by: Pyetro
      // New feature: Check if field value is "0,00" and Backspace was pressed, so clean Val
      // Accept decimals "." or ","
      var MoneyOptsMinus = {
         reverse: true,
         maxlength: false,
         placeholder: '0,00',
         byPassKeys: [9, 16, 17, 18, 35, 36, 37, 38, 39, 40, 46, 91],
         eventNeedChanged: false,
         onKeyPress: function (v, ev, curField, opts) {
            var mask = curField.data('mask').mask;
            var decimalSep = (/0(.)00/gi).exec(mask)[1] || ',';

            opts.prefixMoney = typeof (opts.prefixMoney) != 'undefined' ? opts.prefixMoney : '';

            if (curField.data('mask-isZero') && curField.data('mask-keycode') == 8)
               $(curField).val('');
            else if (v) {
               var key = curField.data('mask-key');
               var minus = (typeof (curField.data('mask-minus-signal')) == 'undefined' ? false : curField.data('mask-minus-signal'));

               if (['-', '+'].indexOf(key) >= 0) {
                  curField.val((opts.prefixMoney) + (key == '-' ? key + v : v.replace(/^-?/, '')));
                  curField.data('mask-minus-signal', key == '-');
                  return;
               }

               // remove previously added stuff at start of string
               v = v.replace(new RegExp('^-?'), '');
               v = v.replace(new RegExp('^0*\\' + decimalSep + '?0*'), ''); //v = v.replace(/^0*,?0*/, '');
               v = v.length == 0 ? '0' + decimalSep + '00' : (v.length == 1 ? '0' + decimalSep + '0' + v : (v.length == 2 ? '0' + decimalSep + v : v));
               curField.val((opts.prefixMoney) + (minus ? '-' : '') + v).data('mask-isZero', (v == '0' + decimalSep + '00'));
            }
         }
      };

      var MoneyOptsPrefix = {};
      MoneyOptsPrefix = $.extend(true, {}, MoneyOptsPrefix, MoneyOptsMinus);
      MoneyOptsPrefix.prefixMoney = 'R$ ';

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-montant-deux-decimal').each(function (i, val) {
            //$(diese.concat(val.id)).mask("#.##0,00", MoneyOptsMinus).keydown().keyup();
            $(diese.concat(val.id)).mask("#.##0,00", {reverse: true});
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurMontant = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurMontant).mask("#.##0,00", MoneyOptsMinus).keydown().keyup();
         });
      }
   };
   //
   // Appliquer le masque pour la saisie de pourcentage
   // 
   item.appliquerMasquePourcentage = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-pourcentage').each(function (i, val) {
            $(diese.concat(val.id)).mask("##0,00%", { reverse: true });
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask("##0,00%", { reverse: true });
         });
      }
   };
   //
   // Appliquer le masque pour la saisie de pourcentage sans signe %
   // 
   item.appliquerMasquePourcentageSansSigne = function (listeItems) {
      var sOptions = {
         reverse: true
      };

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-pourcentage-sans-signe').each(function (i, val) {
            $(diese.concat(val.id)).mask("##0,00", sOptions);
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask("##0,00", sOptions);
         });
      }
   };
   //
   // Appliquer le masque pour le numerique 2 décimales
   // 
   item.appliquerMasqueNumeriqueDeuxDecimales = function (listeItems) {

      var sOptions = {
         reverse: true,
         translation: {
            'S': {
               pattern: /-|\d/,
               recursive: true
            }
         },
         onChange: function (value, e) {
            var target = e.target,
               position = target.selectionStart; // Capture initial position

            target.value = value.replace(/(?!^)-/g, '').replace(/^,/, '').replace(/^-(,| )/, '-');

            target.selectionEnd = position;
         }
      };

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-numerique-2d').each(function (i, val) {
            $(diese.concat(val.id)).mask(" 00 000 000 009,99", sOptions);
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask(" 00 000 000 009,99", sOptions);
         });
      }
   };
   //
   // Appliquer le masque pour le numerique aucune decimal
   // 
   item.appliquerMasqueNumeriqueSansDecimal = function (listeItems) {

      var sOptions = {
         reverse: true,
         translation: {
            'S': {
               pattern: /-|\d/,
               recursive: false
            }
         },
         onChange: function (value, e) {
            var target = e.target,
               position = target.selectionStart; // Capture initial position

            target.value = value.replace(/(?!^)-/g, '').replace(/^,/, '').replace(/^-(,| )/, '-');

            target.selectionEnd = position;
         }
      };

      listeItems = listeItems === undefined ? '' : listeItems;
      if (listeItems.length === 0) {
         $('.shq-numerique-sans-decimal').each(function (i, val) {
            $(diese.concat(val.id)).mask(" 00 000 000 009", sOptions);
         });
      } else {
         $.each(listeItems, function (i, val) {
            var selecteurPourcent = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            $(selecteurPourcent).mask(" 00 000 000 009", sOptions);
         });
      }
   };
   //
   // Permet de changer le libellé d'un item APEX
   // 
   item.changerLibelle = function (nomItemApex, nouveauLiblle) {
      var selecteurLibelle = nomItemApex.concat('_LABEL');
      selecteurLibelle = selecteurLibelle.indexOf(diese, 0) === -1 ? diese.concat(selecteurLibelle) : selecteurLibelle;
      if (selecteurLibelle !== undefined) {
         $(selecteurLibelle).text(nouveauLiblle);
      } else {
         apex.debug.log('Impossible de changer le libellé ', nomItemApex);
      }
   };
   //
   // Uppercase 
   // 
   item.appliquerMajuscule = function (document) {
      $(document).on('change', '.shq-uppercase', function (event) {
         var eventTarget = event.target;
         var elementJqApex = "#" + $(eventTarget).attr("id");
         $(elementJqApex).val($(elementJqApex).val().toUpperCase());
      });
   };

   // Applique le masque pour le format de code suivant : Premier caractère -> majuscule, caractères suivants -> chiffres, majuscules, _, -
   item.appliquerMasqueCodeDebutAlpha = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'Z': {
               pattern: /[A-Za-z]+/,
               recursive: true
            },
            '0': {
               pattern: /[A-Za-z0-9_\-]+/,
               recursive: true
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-debut-alpha').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[A-Z]+[A-Z0-9_\-]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_DEBUT_ALPHA_INVALID");

            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            //item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            // item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);
         });
      }
   };

   // Applique le masque pour le format de code suivant : Premier caractère -> majuscule ou chiffre, caractères suivants -> chiffres, majuscules, _, -
   item.appliquerMasqueCodeAlphaNum = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'Z': {
               pattern: /[A-Za-z0-9]+/,
               recursive: true
            },
            '0': {
               pattern: /[A-Za-z0-9_\-]+/,
               recursive: true
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-alpha-num').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[A-Z0-9]+[A-Z0-9_\-]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_ALPHA_NUM_INVALID");

            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            // item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask('Z' + repeatStringNumTimes('0', item$[0].maxLength - 1), optionsMask);
            // item$.mask('Z' + '0'.repeat(item$[0].maxLength - 1), optionsMask);
         });
      }
   };

   // Applique le masque pour le format de code suivant : Numéro de TVQ
   item.appliquerMasqueTvq = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'T': {
               pattern: /[t]|[T]/,
               fallback: 'T'
            },
            'Q': {
               pattern: /[Q]|[q]/,
               fallback: 'Q'
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-tvq').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('([0-9]{10})(\T|\t)(\Q|\q)([0-9]{04})');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_TVQ_INVALID");

            item$.mask('0000000000TQ0000', optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);

            item$.mask('0000000000TQ0000', optionsMask);

         });
      }
   };

   // Applique le masque pour le format de code suivant : Numéro de TVQ
   item.appliquerMasqueTps = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         translation: {
            'R': {
               pattern: /[r]|[R]/,
               fallback: 'R'
            },
            'T': {
               pattern: /[t]|[T]/,
               fallback: 'T'
            }
         },
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-tps').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('([0-9]{9})(R|r)(T|t)([0-9]{04})');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_TPS_INVALID");

            item$.mask('000000000RT0000', optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);

            item$.mask('000000000RT0000', optionsMask);

         });
      }
   };

   // Applique le masque pour le format de code suivant : Ne doit contenir que des chiffres
   item.appliquerMasqueCodeNum = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      if (listeItems.length === 0) {
         $('.shq-code-num').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[0-9]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_NUM_INVALID");
            item$.mask('0' + repeatStringNumTimes('0', item$[0].maxLength - 1));
            //item$.mask('0'.repeat(item$[0].maxLength - 1));

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask('0' + repeatStringNumTimes('0', item$[0].maxLength - 1));
            // item$.mask('0'.repeat(item$[0].maxLength - 1));
         });
      }
   };

   // Applique le masque pour le format de code suivant : Ne doit contenir que des majuscules
   item.appliquerMasqueCodeAlpha = function (listeItems) {
      listeItems = listeItems === undefined ? '' : listeItems;

      var optionsMask = {
         onKeyPress: function (value, event) {
            event.currentTarget.value = value.toUpperCase();
         }
      };

      if (listeItems.length === 0) {
         $('.shq-code-alpha').each(function (i, val) {
            var l_item = val.id;
            var item$ = $(diese.concat(l_item));
            var l_regexp = new RegExp('[A-Z]*');
            var l_message = apex.lang.formatMessage("SHQ.ITEM.CODE_ALPHA_INVALID");
            item$.mask(repeatStringNumTimes('S', item$[0].maxLength), optionsMask);
            // item$.mask('S'.repeat(item$[0].maxLength - 1), optionsMask);

            if (item$.is('pattern') === false) {
               item$.attr('pattern', l_regexp.source);
               item$.attr('data-valid-message', l_message);
            }
         });
      }
      else {
         $.each(listeItems, function (i, val) {
            var selecteur = val.indexOf(diese, 0) === -1 ? diese.concat(val) : val;
            var item$ = $(selecteur);
            item$.mask(repeatStringNumTimes('S', item$[0].maxLength), optionsMask);
            // item$.mask('S'.repeat(item$[0].maxLength - 1), optionsMask);
         });
      }
   };

   // 
   // Permet de vérifier si le enter a été pressé
   // 
   item.enterPresse = function (event) {
      var keyEnter = "Enter";
      var key = event.key === undefined ? null : event.key;
      return key === keyEnter ? true : false;
   };
   item.controlerInputPassword = function (event) {
      var classIconMasque = "fa-eye-slash";
      var classIconView = "fa-eye";

      var $button = $(this);
      var $spanButtonIcon = $("span", $button);
      var idInputPassword = diese.concat($button.data("id-input"));
      //
      // Ajust le type de la balise input du password
      // 
      var typeInput = $(idInputPassword).attr('type') === "password" ? "text" : "password";
      $(idInputPassword).attr("type", typeInput);
      //
      // Ajust l'icon selon le type de la balise input
      // 
      if (typeInput === "text") {
         $spanButtonIcon.removeClass(classIconView)
            .addClass(classIconMasque);
      } else {
         $spanButtonIcon.removeClass(classIconMasque)
            .addClass(classIconView);
      }

   };
   item.visualiserInputPassword = function () {
      //
      // Applique la visualisation du mot de passe pour les éléments input de type password 
      // 
      $('.shq-visualiser-password').on("click", shq.item.controlerInputPassword);

   };

   //
   // Objet shq,apex,Jquery
   //
})(shq.item, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.page = {};

(function (shq, page, ut, $) {
   "use strict";
   // 
   // Permet d'afficher une boite de confimation avec des libellés différent sur les boutons.
   //
   shq.page.confirm = function (pMessage, pCallback, pOkLabel, pCancelLabel) {
      //
      // Valeur original des boutons
      //
      var l_original_boutons = {
         "APEX.DIALOG.OK": apex.lang.getMessage("APEX.DIALOG.OK"),
         "APEX.DIALOG.CANCEL": apex.lang.getMessage("APEX.DIALOG.CANCEL")
      };
      //
      //change les libellés des bouton 
      //      
      apex.lang.addMessages({ "APEX.DIALOG.OK": pOkLabel });
      apex.lang.addMessages({ "APEX.DIALOG.CANCEL": pCancelLabel });
      //
      // Affiche la boite de dialogue
      //
      apex.message.confirm(pMessage, pCallback);
      //
      //the timeout is required since APEX 19.2 due to a change in the apex.message.confirm
      //
      setTimeout(function () {
         // Remet les boutons à leur valeur ortiginal
         apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_boutons["APEX.DIALOG.OK"] });
         apex.lang.addMessages({ "APEX.DIALOG.CANCEL": l_original_boutons["APEX.DIALOG.CANCEL"] });
      }, 0);
   };
   shq.page.alert = function (pMessage, pCallback, pOkLabel) {
      //
      // Valeur original des boutons
      //
      var l_original_boutons = {
         "APEX.DIALOG.OK": apex.lang.getMessage("APEX.DIALOG.OK"),
      };
      //
      //change les libellés des bouton 
      //      
      apex.lang.addMessages({ "APEX.DIALOG.OK": pOkLabel });      
      //
      // Affiche la boite de dialogue
      //
      apex.message.alert(pMessage, pCallback);
       //
      //the timeout is required since APEX 19.2 due to a change in the apex.message.confirm
      //
      setTimeout(function () {
         // Remet les boutons à leur valeur ortiginal
         apex.lang.addMessages({ "APEX.DIALOG.OK": l_original_boutons["APEX.DIALOG.OK"] });
      }, 0);
   };
})(shq, shq.page, apex.util, apex.jQuery);
/* global apex */
/* global moment */
var shq = shq || {};
shq.region = {};

(function (region, shq, ut, $) {
    "use strict";
    //
    var C_LOG_DEBUG = apex.debug.LOG_LEVEL.INFO;
    var diese = '#';

    region.appliquerSpinnerIframe = function (regionId) {

        var region$ = $(diese.concat(regionId)),
            iframe$ = region$.find('iframe'),
            lSpinner$ = apex.util.showSpinner();

        iframe$.on('load', function () {
            lSpinner$.remove();

        });
    };
})(shq.region, shq, apex.theme42, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.utl_menu = {};
//
// fonction pour le menu shq
//
(function (utl_menu, shq, $) {
   "use strict";
   //
   // Gestion de l'autoration DEV pour APEX
   // 
   utl_menu.appliquerCssAutorisationDev = function (autoration) {
      var codeOui = 'O';
      var codeNon = 'N';
      var classAutoBg = 'u-warning',
         classeAutoTexte = 'u-normal-text';
      var selAutorisationDev = $('.t-NavigationBar a.t-Button.t-Button--icon.t-Button--header.t-Button--navBar .fa-user-secret').parent();
      
      if (selAutorisationDev.length) {
         switch (autoration) {
            case codeOui:
               $(selAutorisationDev).removeClass(classAutoBg)
                  .removeClass(classeAutoTexte);
               break;
            case codeNon:
               $(selAutorisationDev).addClass(classAutoBg)
                  .addClass(classeAutoTexte);
               break;
            default:
               $(selAutorisationDev).removeClass(classAutoBg)
                  .removeClass(classeAutoTexte);
               break;
         }
      }
   };
   utl_menu.initialiserAutorisationDev = function () {
      var processAutorisationDev = 'APX - Recuperer Autorisation DEV';
      var messageErreurAjax = '"ERREUR_MESSAGE_AJAX"';

      apex.server.process(processAutorisationDev)
         .done(function (data) {
            apex.debug.info(data);
            utl_menu.appliquerCssAutorisationDev(data.autorisation_dev.valeur);
         })
         .fail(function () {
            messageErreurAjax = messageErreurAjax.replace('%1', 'processAutorisationDev');
            apex.message.showErrors(messageErreurAjax);
            apex.debug.error(messageErreurAjax);
         });
   };
   utl_menu.appliquerAutorisationDev = function () {
      var processAutorisationDev = 'APX - MAJ Autorisation DEV';
      var messageErreurAjax = '"ERREUR_MESSAGE_AJAX"';

      apex.server.process(processAutorisationDev)
         .done(function (data) {
            apex.debug.info(data);
            utl_menu.appliquerCssAutorisationDev(data.autorisation_dev.valeur);
            apex.message.showPageSuccess(data.autorisation_dev.message);
         })
         .fail(function () {
            messageErreurAjax = messageErreurAjax.replace('%1', 'processAutorisationDev');
            apex.message.showErrors(messageErreurAjax);
            apex.debug.error(messageErreurAjax);
         });
   };
   //
   // Contrôle le libellé du champs NOM_FONCT_PLSQL_LIBEL
   // 
   utl_menu.controlerLibelleFonctExpression = function (codeTypeLibelle) {
      var libellePlsql = 'Nom de la fonction PL/SQL';
      var libelleExpressionSql = 'Expression SQL';
      var codePLSQL = 'PLSQL';
      var codeExpre = 'EXPRE';
      var libelle;
      var nomItemApex = 'P9_NOM_FONCT_PLSQL_LIBEL';

      switch (codeTypeLibelle) {
         case codePLSQL:
            libelle = libellePlsql;
            break;
         case codeExpre:
            libelle = libelleExpressionSql;
            break;
         default:
            libelle = libellePlsql;
      }
      shq.item.changerLibelle(nomItemApex, libelle);
   };
   //
   // Contrôle le libellé du champs NO_SEQ_PORTAIL_APPLI
   // 
   utl_menu.controlerLibellePortailAppli = function (TypeAppli) {
      var libelleApex = 'Application APEX';
      var libelleForms = 'Application FORMS';
      var codeApex = 'APEX';
      var codeForms = 'FORMS';
      var libelle;
      var nomItemApex = 'P9_NO_SEQ_PORTAIL_APPLI';

      switch (TypeAppli) {
         case codeApex:
            libelle = libelleApex;
            break;
         case codeForms:
            libelle = libelleForms;
            break;
         default:
            libelle = libelleApex;
      }
      shq.item.changerLibelle(nomItemApex, libelle);
   };
   shq.utl_menu.ouvrirLiensUrlFichier = function (fileUrl) {
      var messageFichierUrl = apex.lang.formatMessageNoEscape("SHQ.MENU.OUVERTURE_FICHIER_URL", fileUrl);
      if (shq.isNavigateurIexplorer11()) {
         var tampon = apex.navigation.openInNewWindow(fileUrl, '', { favorTabbedBrowsing: true });
      } else {
         apex.message.alert(messageFichierUrl);
      }
   };
   shq.utl_menu.ouvrirLiensForms = function (formUrl, nomApplication) {
      var messageFormsUrl = apex.lang.formatMessageNoEscape("SHQ.MENU.OUVERTURE_FORMS", nomApplication);
      /* 
       * Permet d'ouvrir plusieurs fenêtres pour une même application form
       * Si même nom de nom d'application il récupère la fenêtre.
      */
      var dateOnglet = new Date();
      var nombreMiliSecondeEcoule = dateOnglet.getTime();
      nomApplication = typeof nomApplication === "undefined" ? "" : nomApplication;
      nomApplication = $nvl(nomApplication, true) ? nomApplication.concat('_').concat(nombreMiliSecondeEcoule) : nombreMiliSecondeEcoule;

      if (shq.isNavigateurIexplorer11() ||
          shq.isNavigateurEdge() ) {
         var width_win = Math.ceil(screen.width * 0.85);
         var height_win = Math.ceil(screen.height * 0.75);
         var tampon = apex.navigation.popup({ url: formUrl, name: nomApplication, width: width_win, height: height_win, menubar: "yes", statusbar: "yes" });
      } else {
         apex.message.alert(messageFormsUrl);
      }
   };
   shq.utl_menu.ouvrirLiensIexplorer = function (Url, nomApplication) {
      var messageFormsUrl = apex.lang.formatMessage("SHQ.MENU.OUVERTURE_URL_IEXPLORER");
      /* 
       * Permet d'ouvrir plusieurs fenêtres pour une même application form
       * Si même nom de nom d'application il récupère la fenêtre.
      */
      var dateOnglet = new Date();
      var nombreMiliSecondeEcoule = dateOnglet.getTime();
      nomApplication = typeof nomApplication === "undefined" ? "" : nomApplication;
      nomApplication = $nvl(nomApplication, true) ? nomApplication.concat('_').concat(nombreMiliSecondeEcoule) : nombreMiliSecondeEcoule;

      if (shq.isNavigateurIexplorer11() ||      
          shq.isNavigateurEdge()) {
         var width_win = Math.ceil(screen.width * 0.85);
         var height_win = Math.ceil(screen.height * 0.75);
         var tampon = apex.navigation.popup({ url: Url, name: nomApplication, width: width_win, height: height_win, menubar: "yes", statusbar: "yes" });
      } else {
         apex.message.alert(messageFormsUrl);
      }
   };
})(shq.utl_menu, shq, apex.jQuery);
/* global apex */

var shq = shq || {};
shq.utl_portail = {};
//
// fonction pour le menu shq
//
(function (utl_portail, shq, $) {
   "use strict";
   //
   // Évenement "binder"  pour l'ouverture et fermeture des applications affectées au messages
   // 
   utl_portail.expandCollapseMessagePortail = function () {
      var target = 'li.t-shq-portail-message';      
      var addRemoveClassMessage = function (event) {
         var currentExpand = 'is-current is-expanded';
         var liTarget = event.currentTarget;

         $(target).not(liTarget).each(function (index, element) {
            $(element).removeClass(currentExpand);
         });

         var bidon =
            $(liTarget).hasClass(currentExpand) ? $(liTarget).removeClass(currentExpand) : $(liTarget).addClass(currentExpand);

      };
     
      $(target).on('click', function (event) {
         addRemoveClassMessage(event);
      });
   };
})(shq.utl_portail, shq, apex.jQuery);
//# sourceMappingURL=shq.js.map
