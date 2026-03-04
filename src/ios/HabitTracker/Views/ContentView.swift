//
//  ContentView.swift
//  HabitTracker
//
//  Created by AIagent on 2026-03-03.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HabitsView()
                .tabItem {
                    Image(systemName: "checkmark.circle.fill")
                    Text("习惯")
                }
                .tag(0)
            
            StatisticsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("统计")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(2)
        }
        .accentColor(Color(hex: "#FD79A8"))
    }
}

struct HabitsView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("今日习惯")) {
                    HabitRow(name: "早起", completed: true, streak: 7)
                    HabitRow(name: "阅读", completed: false, streak: 5)
                    HabitRow(name: "运动", completed: false, streak: 12)
                }
            }
            .navigationTitle("习惯")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct HabitRow: View {
    let name: String
    let completed: Bool
    let streak: Int
    
    var body: some View {
        HStack {
            Image(systemName: completed ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 24))
                .foregroundColor(completed ? Color(hex: "#FD79A8") : .gray)
            
            Text(name)
                .font(.system(size: 16))
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(streak)")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatisticsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                StatCard(title: "今日完成", value: "1/3", color: "#FD79A8")
                StatCard(title: "本周完成", value: "15/21", color: "#6C5CE7")
                StatCard(title: "最长连续", value: "12 天", color: "#00B894")
                
                Spacer()
            }
            .padding()
            .navigationTitle("统计")
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: String
    
    var body: some View {
        VStack(spacing: 15) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color(hex: color))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

struct SettingsView: View {
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("关于")) {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
        }
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    ContentView()
}
