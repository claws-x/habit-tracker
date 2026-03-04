//
//  HabitManager.swift
//  HabitTracker
//
//  Created by AIagent on 2026-03-03.
//

import Foundation
import UserNotifications

/// 习惯管理器 - 真实习惯追踪
class HabitManager: ObservableObject {
    // MARK: - Published Properties
    @Published var habits: [Habit] = []
    @Published var todayCompletions: [String: Bool] = [:]
    @Published var streak: Int = 0
    
    // MARK: - Computed Properties - 真实计算
    var completedToday: Int {
        todayCompletions.filter { $0.value }.count
    }
    
    var totalHabits: Int {
        habits.count
    }
    
    var completionRate: Double {
        guard totalHabits > 0 else { return 0 }
        return Double(completedToday) / Double(totalHabits)
    }
    
    // MARK: - Constants
    private let habitsKey = "user_habits"
    private let completionsKey = "habit_completions"
    
    // MARK: - Initialization
    init() {
        loadHabits()
        loadCompletions()
        checkNewDay()
        setupNotifications()
    }
    
    // MARK: - Methods - 真实功能
    func addHabit(_ habit: Habit) {
        habits.append(habit)
        saveHabits()
    }
    
    func toggleCompletion(for habitId: String) {
        todayCompletions[habitId] = !(todayCompletions[habitId] ?? false)
        saveCompletions()
        
        if let index = habits.firstIndex(where: { $0.id.uuidString == habitId }) {
            if todayCompletions[habitId] == true {
                habits[index].completedToday = true
                habits[index].currentStreak += 1
            } else {
                habits[index].completedToday = false
                habits[index].currentStreak = 0
            }
            saveHabits()
        }
    }
    
    func deleteHabit(at offsets: IndexSet) {
        habits.remove(atOffsets: offsets)
        saveHabits()
    }
    
    // MARK: - Daily Reset - 真实每日重置
    private func checkNewDay() {
        let calendar = Calendar.current
        let today = Date()
        
        if let lastCheck = UserDefaults.standard.object(forKey: "last_check_date") as? Date,
           !calendar.isDateInToday(lastCheck) {
            // 新的一天，重置完成状态
            resetDailyCompletions()
        }
        
        UserDefaults.standard.set(today, forKey: "last_check_date")
    }
    
    private func resetDailyCompletions() {
        // 保存昨天的 streak 数据
        saveHabits()
        
        // 重置今日完成状态
        todayCompletions.removeAll()
        
        // 重置习惯的今日完成状态
        for index in habits.indices {
            habits[index].completedToday = false
        }
        
        saveCompletions()
        saveHabits()
    }
    
    // MARK: - Persistence - 真实数据保存
    private func saveHabits() {
        if let data = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(data, forKey: habitsKey)
        }
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: habitsKey),
              let habits = try? JSONDecoder().decode([Habit].self, from: data) else {
            return
        }
        self.habits = habits
    }
    
    private func saveCompletions() {
        if let data = try? JSONEncoder().encode(todayCompletions) {
            UserDefaults.standard.set(data, forKey: completionsKey)
        }
    }
    
    private func loadCompletions() {
        guard let data = UserDefaults.standard.data(forKey: completionsKey),
              let completions = try? JSONDecoder().decode([String: Bool].self, from: data) else {
            return
        }
        todayCompletions = completions
    }
    
    // MARK: - Statistics - 真实统计
    func getWeeklyCompletionRate() -> Double {
        let calendar = Calendar.current
        let today = Date()
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: today) ?? today
        
        var completed = 0
        var total = 0
        
        for habit in habits {
            total += 7 // 一周 7 天
            completed += habit.completedDays(in: weekAgo...today)
        }
        
        guard total > 0 else { return 0 }
        return Double(completed) / Double(total)
    }
    
    func getTotalStreak() -> Int {
        habits.map { $0.currentStreak }.max() ?? 0
    }
    
    // MARK: - Notifications - 真实提醒
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("✅ 通知权限已获取")
            }
        }
    }
    
    func scheduleDailyReminder(hour: Int = 20) {
        let content = UNMutableNotificationContent()
        content.title = "📝 习惯打卡提醒"
        content.body = "今天的目标完成了吗？"
        content.sound = .default
        
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "daily_habit_reminder",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
}

// MARK: - Data Models
struct Habit: Identifiable, Codable {
    let id: UUID
    var name: String
    var color: String
    var icon: String
    var targetDays: [Int] // 1-7 (周一到周日)
    var currentStreak: Int
    var bestStreak: Int
    var completedToday: Bool
    var completionHistory: [Date: Bool]
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String = "#FD79A8",
        icon: String = "checkmark.circle.fill",
        targetDays: [Int] = [1, 2, 3, 4, 5, 6, 7],
        currentStreak: Int = 0,
        bestStreak: Int = 0,
        completedToday: Bool = false,
        completionHistory: [Date: Bool] = [:]
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.targetDays = targetDays
        self.currentStreak = currentStreak
        self.bestStreak = bestStreak
        self.completedToday = completedToday
        self.completionHistory = completionHistory
    }
    
    func completedDays(in range: ClosedRange<Date>) -> Int {
        completionHistory.filter { date, completed in
            completed && range.contains(date)
        }.count
    }
}
