pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool khalAvailable: false
    property var eventsByDate: ({})
    property bool isLoading: false
    property string lastError: ""
    property date lastStartDate
    property date lastEndDate
    property string khalDateFormat: "MM/dd/yyyy"

    function checkKhalAvailability() {
        if (!khalCheckProcess.running)
            khalCheckProcess.running = true
    }

    function detectKhalDateFormat() {
        if (!khalFormatProcess.running)
            khalFormatProcess.running = true
    }

    function parseKhalDateFormat(formatExample) {
        let qtFormat = formatExample.replace("12", "MM").replace("21", "dd").replace("2013", "yyyy")
        return { format: qtFormat, parser: null }
    }


    function loadCurrentMonth() {
        if (!root.khalAvailable)
            return

        let today = new Date()
        let firstDay = new Date(today.getFullYear(), today.getMonth(), 1)
        let lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0)
        let startDate = new Date(firstDay)
        startDate.setDate(startDate.getDate() - firstDay.getDay() - 7)
        let endDate = new Date(lastDay)
        endDate.setDate(endDate.getDate() + (6 - lastDay.getDay()) + 7)
        loadEvents(startDate, endDate)
    }

    function loadEvents(startDate, endDate) {
        if (!root.khalAvailable) {
            return
        }
        if (eventsProcess.running) {
            return
        }
        root.lastStartDate = startDate
        root.lastEndDate = endDate
        root.isLoading = true
        let startDateStr = Qt.formatDate(startDate, root.khalDateFormat)
        let endDateStr = Qt.formatDate(endDate, root.khalDateFormat)
        eventsProcess.requestStartDate = startDate
        eventsProcess.requestEndDate = endDate
        eventsProcess.command = ["khal", "list", "--json", "title", "--json", "description", "--json", "start-date", "--json", "start-time", "--json", "end-date", "--json", "end-time", "--json", "all-day", "--json", "location", "--json", "url", startDateStr, endDateStr]
        eventsProcess.running = true
    }

    function getEventsForDate(date) {
        let dateKey = Qt.formatDate(date, "yyyy-MM-dd")
        return root.eventsByDate[dateKey] || []
    }

    function hasEventsForDate(date) {
        let events = getEventsForDate(date)
        return events.length > 0
    }

    Component.onCompleted: {
        detectKhalDateFormat()
    }

    Process {
        id: khalFormatProcess

        command: ["khal", "printformats"]
        running: false
        onExited: exitCode => {
            if (exitCode !== 0) {
                checkKhalAvailability()
            }
        }

        stdout: StdioCollector {
            onStreamFinished: {
                let lines = text.split('\n')
                for (let line of lines) {
                    if (line.startsWith('dateformat:')) {
                        let formatExample = line.substring(line.indexOf(':') + 1).trim()
                        let formatInfo = parseKhalDateFormat(formatExample)
                        root.khalDateFormat = formatInfo.format
                        break
                    }
                }
                checkKhalAvailability()
            }
        }
    }

    Process {
        id: khalCheckProcess

        command: ["khal", "list", "today"]
        running: false
        onExited: exitCode => {
            root.khalAvailable = (exitCode === 0)
            if (exitCode === 0) {
                loadCurrentMonth()
            }
        }
    }

    Process {
        id: eventsProcess

        property date requestStartDate
        property date requestEndDate
        property string rawOutput: ""

        running: false
        onExited: exitCode => {
            root.isLoading = false
            if (exitCode !== 0) {
                root.lastError = "Failed to load events (exit code: " + exitCode + ")"
                return
            }
            try {
                let newEventsByDate = {}
                let lines = eventsProcess.rawOutput.split('\n')
                for (let line of lines) {
                    line = line.trim()
                    if (!line || line === "[]")
                    continue

                    let dayEvents = JSON.parse(line)
                    for (let event of dayEvents) {
                        if (!event.title)
                        continue

                        let startDate, endDate
                        if (event['start-date']) {
                            startDate = Date.fromLocaleString(Qt.locale(), event['start-date'], root.khalDateFormat)
                        } else {
                            startDate = new Date()
                        }
                        if (event['end-date']) {
                            endDate = Date.fromLocaleString(Qt.locale(), event['end-date'], root.khalDateFormat)
                        } else {
                            endDate = new Date(startDate)
                        }
                        let startTime = new Date(startDate)
                        let endTime = new Date(endDate)
                        if (event['start-time']
                            && event['all-day'] !== "True") {
                            let timeStr = event['start-time']
                            if (timeStr) {
                                let timeParts = timeStr.match(/(\d+):(\d+)/)
                                if (timeParts) {
                                    startTime.setHours(parseInt(timeParts[1]),
                                                       parseInt(timeParts[2]))
                                    if (event['end-time']) {
                                        let endTimeParts = event['end-time'].match(
                                            /(\d+):(\d+)/)
                                        if (endTimeParts)
                                        endTime.setHours(
                                            parseInt(endTimeParts[1]),
                                            parseInt(endTimeParts[2]))
                                    } else {
                                        endTime = new Date(startTime)
                                        endTime.setHours(
                                            startTime.getHours() + 1)
                                    }
                                }
                            }
                        }
                        let eventId = event.title + "_" + event['start-date']
                        + "_" + (event['start-time'] || 'allday')
                        let eventTemplate = {
                            "id": eventId,
                            "title": event.title || "Untitled Event",
                            "start": startTime,
                            "end": endTime,
                            "location": event.location || "",
                            "description": event.description || "",
                            "url": event.url || "",
                            "calendar": "",
                            "color": "",
                            "allDay": event['all-day'] === "True",
                            "isMultiDay": startDate.toDateString(
                                              ) !== endDate.toDateString()
                        }
                        let currentDate = new Date(startDate)
                        while (currentDate <= endDate) {
                            let dateKey = Qt.formatDate(currentDate,
                                                        "yyyy-MM-dd")
                            if (!newEventsByDate[dateKey])
                            newEventsByDate[dateKey] = []

                            let existingEvent = newEventsByDate[dateKey].find(
                                e => {
                                    return e.id === eventId
                                })
                            if (existingEvent) {
                                currentDate.setDate(currentDate.getDate() + 1)
                                continue
                            }
                            let dayEvent = Object.assign({}, eventTemplate)
                            if (currentDate.getTime() === startDate.getTime()) {
                                dayEvent.start = new Date(startTime)
                            } else {
                                dayEvent.start = new Date(currentDate)
                                if (!dayEvent.allDay)
                                dayEvent.start.setHours(0, 0, 0, 0)
                            }
                            if (currentDate.getTime() === endDate.getTime()) {
                                dayEvent.end = new Date(endTime)
                            } else {
                                dayEvent.end = new Date(currentDate)
                                if (!dayEvent.allDay)
                                dayEvent.end.setHours(23, 59, 59, 999)
                            }
                            newEventsByDate[dateKey].push(dayEvent)
                            currentDate.setDate(currentDate.getDate() + 1)
                        }
                    }
                }
                for (let dateKey in newEventsByDate) {
                    newEventsByDate[dateKey].sort((a, b) => {
                                                      return a.start.getTime(
                                                          ) - b.start.getTime()
                                                  })
                }
                root.eventsByDate = newEventsByDate
                root.lastError = ""
            } catch (error) {
                root.lastError = "Failed to parse events JSON: " + error.toString()
                root.eventsByDate = {}
            }
            eventsProcess.rawOutput = ""
        }

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                eventsProcess.rawOutput += data + "\n"
            }
        }
    }
}
