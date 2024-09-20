import SwiftUI

struct E85CalculatorView: View {
    // Input fields
    @State private var tankSize: String = ""
    @State private var ethanolContentAtPump: String = ""
    @State private var pumpGasEthanol: String = ""
    @State private var targetEthanol: String = ""
    @State private var currentEthanol: String = ""
    @State private var fuelLevel: Double = 0.5  // Default to 50%

    // Output fields
    @State private var ethanolToAdd: Double = 0.0
    @State private var pumpGasToAdd: Double = 0.0
    @State private var resultingMix: Double = 0.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // Input Fields
                Group {
                    TextField("Gas Tank Size (e.g., 15)", text: $tankSize)
                        .keyboardType(.decimalPad)
                    TextField("Ethanol Content at Pump (%) (e.g., 85)", text: $ethanolContentAtPump)
                        .keyboardType(.decimalPad)
                    TextField("Pump Gas Ethanol (%) (e.g., 10)", text: $pumpGasEthanol)
                        .keyboardType(.decimalPad)
                    TextField("Target Ethanol (%) (e.g., 30)", text: $targetEthanol)
                        .keyboardType(.decimalPad)
                    TextField("Current Ethanol (%) (e.g., 10)", text: $currentEthanol)
                        .keyboardType(.decimalPad)
                }
                .textFieldStyle(RoundedBorderTextFieldStyle())

                // Fuel Level Slider
                VStack {
                    Text("Fuel Level: \(Int(fuelLevel * 100))%")
                    Slider(value: $fuelLevel, in: 0...1, step: 0.01)
                }

                // Calculate Button
                Button(action: calculate) {
                    Text("Calculate")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                // Output Fields
                Group {
                    Text("Ethanol to Add: \(ethanolToAdd, specifier: "%.2f") units")
                    Text("Pump Gas to Add: \(pumpGasToAdd, specifier: "%.2f") units")
                    Text("Resulting Mix: \(resultingMix * 100, specifier: "%.2f")% Ethanol")
                }
                .font(.headline)

                Spacer()
            }
            .padding()
        }
    }

    func calculate() {
        // Convert input strings to Double
        guard let Vt = Double(tankSize),
              let E_ethanol_pump_percent = Double(ethanolContentAtPump),
              let E_pump_gas_percent = Double(pumpGasEthanol),
              let E_target_percent = Double(targetEthanol),
              let E_current_percent = Double(currentEthanol) else {
            // Invalid input, reset outputs
            ethanolToAdd = 0.0
            pumpGasToAdd = 0.0
            resultingMix = 0.0
            return
        }

        // Convert percentages to fractions
        let E_current_fraction = E_current_percent / 100.0
        let E_ethanol_pump_fraction = E_ethanol_pump_percent / 100.0
        let E_pump_gas_fraction = E_pump_gas_percent / 100.0
        let E_target_fraction = E_target_percent / 100.0

        // Current fuel volume
        let V_current = Vt * fuelLevel

        // Total ethanol in current fuel
        let E_current_total = V_current * E_current_fraction

        // Denominator for calculation
        let denominator = E_ethanol_pump_fraction - E_pump_gas_fraction

        if denominator == 0 {
            // Avoid division by zero
            ethanolToAdd = 0.0
            pumpGasToAdd = 0.0
            resultingMix = 0.0
            return
        }

        // Numerator for calculation
        let numerator = Vt * (E_target_fraction - E_pump_gas_fraction) + V_current * (E_pump_gas_fraction - E_current_fraction)

        // Volume of ethanol to add
        let Ve = numerator / denominator

        // Volume of pump gas to add
        let Vp = Vt - V_current - Ve

        // Check for negative values
        if Ve.isNaN || Vp.isNaN || Ve < 0 || Vp < 0 {
            ethanolToAdd = 0.0
            pumpGasToAdd = 0.0
            resultingMix = 0.0
            return
        }

        // Update outputs
        ethanolToAdd = Ve
        pumpGasToAdd = Vp

        // Compute resulting mix ethanol content
        let E_total = E_current_total + Ve * E_ethanol_pump_fraction + Vp * E_pump_gas_fraction
        let V_total = V_current + Ve + Vp
        let E_resulting_mix = E_total / V_total

        resultingMix = E_resulting_mix
    }
}

struct ContentView: View {
    var body: some View {
        E85CalculatorView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

