//
//  DateExtensionTests.swift
//  RelayanceTests
//

import XCTest
@testable import Relayance

final class DateExtensionTests: XCTestCase {

    // MARK: - dateFromString(_:)

    func testGivenValidFullDateString_WhenCallingDateFromString_ThenReturnsExpectedDate() {
        // Given
        let validDateString = "2024-07-10"

        // When
        let result = Date.dateFromString(validDateString)

        // Then
        XCTAssertNotNil(result, "A valid yyyy-MM-dd string should parse to a non-nil Date.")
        XCTAssertEqual(result?.getYear(), 2024)
        XCTAssertEqual(result?.getMonth(), 7)
        XCTAssertEqual(result?.getDay(), 10)
    }

    func testGivenIsoStringWithTimeComponent_WhenCallingDateFromString_ThenReturnsNil() {
        // Given
        // .withFullDate alone does not accept a time/timezone suffix, so this must fail to parse.
        let isoStringWithTime = "2024-07-10T14:30:00.000Z"

        // When
        let result = Date.dateFromString(isoStringWithTime)

        // Then
        XCTAssertNil(result, "A full ISO8601 string including time should not parse with the .withFullDate-only formatter.")
    }

    func testGivenCompletelyInvalidString_WhenCallingDateFromString_ThenReturnsNil() {
        // Given
        let invalidString = "ceci-n-est-pas-une-date"

        // When
        let result = Date.dateFromString(invalidString)

        // Then
        XCTAssertNil(result, "An unparsable string should return nil.")
    }

    func testGivenEmptyString_WhenCallingDateFromString_ThenReturnsNil() {
        // Given
        let emptyString = ""

        // When
        let result = Date.dateFromString(emptyString)

        // Then
        XCTAssertNil(result, "An empty string should return nil.")
    }

    // MARK: - stringFromDate(_:)

    func testGivenKnownDate_WhenCallingStringFromDate_ThenReturnsFormattedDDMMYYYYString() {
        // Given
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 10
        let knownDate = Calendar.current.date(from: components)!

        // When
        let result = Date.stringFromDate(knownDate)

        // Then
        XCTAssertEqual(result, "10-07-2024", "stringFromDate should format the date as dd-MM-yyyy.")
    }

    func testGivenAnotherKnownDate_WhenCallingStringFromDate_ThenReturnsFormattedDDMMYYYYString() {
        // Given
        var components = DateComponents()
        components.year = 2021
        components.month = 1
        components.day = 5
        let knownDate = Calendar.current.date(from: components)!

        // When
        let result = Date.stringFromDate(knownDate)

        // Then
        XCTAssertEqual(result, "05-01-2021", "stringFromDate should zero-pad single digit day and month values.")
    }

    // MARK: - getDay()

    func testGivenKnownDate_WhenCallingGetDay_ThenReturnsExpectedDayComponent() {
        // Given
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 10
        let knownDate = Calendar.current.date(from: components)!

        // When
        let day = knownDate.getDay()

        // Then
        XCTAssertEqual(day, 10, "getDay should return the day component of the date.")
    }

    // MARK: - getMonth()

    func testGivenKnownDate_WhenCallingGetMonth_ThenReturnsExpectedMonthComponent() {
        // Given
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 10
        let knownDate = Calendar.current.date(from: components)!

        // When
        let month = knownDate.getMonth()

        // Then
        XCTAssertEqual(month, 7, "getMonth should return the month component of the date.")
    }

    // MARK: - getYear()

    func testGivenKnownDate_WhenCallingGetYear_ThenReturnsExpectedYearComponent() {
        // Given
        var components = DateComponents()
        components.year = 2024
        components.month = 7
        components.day = 10
        let knownDate = Calendar.current.date(from: components)!

        // When
        let year = knownDate.getYear()

        // Then
        XCTAssertEqual(year, 2024, "getYear should return the year component of the date.")
    }

    // MARK: - Combined: getDay / getMonth / getYear on Date.now

    func testGivenCurrentDate_WhenCallingAllGetters_ThenComponentsMatchCalendarComponents() {
        // Given
        let now = Date.now
        let expectedDay = Calendar.current.component(.day, from: now)
        let expectedMonth = Calendar.current.component(.month, from: now)
        let expectedYear = Calendar.current.component(.year, from: now)

        // When
        let day = now.getDay()
        let month = now.getMonth()
        let year = now.getYear()

        // Then
        XCTAssertEqual(day, expectedDay, "getDay should match Calendar's day component for Date.now.")
        XCTAssertEqual(month, expectedMonth, "getMonth should match Calendar's month component for Date.now.")
        XCTAssertEqual(year, expectedYear, "getYear should match Calendar's year component for Date.now.")
    }
}
