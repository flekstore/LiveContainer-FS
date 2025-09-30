//
//  AgeConfirmationView.swift
//  LiveContainer
//
//  Created by Alexander Grigoryev on 01.10.2025.
//

import SwiftUI

struct AgeConfirmationView: View {
    @AppStorage("isAdult") private var isAdult: Bool = false
    @State private var showYearPicker = false
    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var alertMessage: String = ""
    @State private var showAlert = false

    let currentYear = Calendar.current.component(.year, from: Date())
    let years: [Int]

    init() {
        self.years = Array(1900...currentYear).reversed()
    }

    var body: some View {
        VStack(spacing: 0) {
            Toggle("Disable Filtering", isOn: Binding(
                get: { isAdult },
                set: { newValue in
                    if newValue {
                        // Only show picker if user tries to enable
                        selectedYear = currentYear - 18
                        showYearPicker = true
                    } else {
                        isAdult = false
                    }
                }
            ))

            if showYearPicker {
                Text("Please confirm you are an adult by selecting your birth year below.")
                    .multilineTextAlignment(.center)
                    .padding()

                Picker("Select your birth year", selection: $selectedYear) {
                    ForEach(years, id: \.self) { year in
                        Text("\(year)").tag(year)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .clipped()

                Button("Confirm") {
                    let age = currentYear - selectedYear
                    if age >= 18 {
                        isAdult = true
                        showYearPicker = false
                    } else {
                        isAdult = false
                        alertMessage = "You must be 18 or older to enable this option."
                        showAlert = true
                    }
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .alert(alertMessage, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        }
    }
}

struct AgeConfirmationView_Previews: PreviewProvider {
    static var previews: some View {
        AgeConfirmationView()
    }
}
