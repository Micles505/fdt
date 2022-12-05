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
