import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ConcurrencyViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            Text(viewModel.userData)
                .font(.title2)
                .padding()
            
            Button("Fetch User Data") {
                Task {
                    await viewModel.fetchUserData()
                }
            }
            .buttonStyle(.borderedProminent)
            
            Button("Fetch Multiple Users") {
                Task {
                    await viewModel.fetchMultipleUsers()
                }
            }
            .buttonStyle(.bordered)
            
            Button("Perform Parallel Operations") {
                Task {
                    await viewModel.performOperations()
                }
            }
            .buttonStyle(.bordered)
            
            Text("Counter: \(viewModel.counterValue)")
                .font(.title2)
                .padding()
            
            Button("Increment Counter") {
                Task {
                    await viewModel.incrementCounter()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

// MARK: - Actor for managing shared state safely
actor Counter {
    private var value = 0
    
    func increment() {
        value += 1
    }
    
    func getValue() -> Int {
        return value
    }
}


// MARK: - ViewModel for handling async tasks
@MainActor
class ConcurrencyViewModel: ObservableObject {
    @Published var userData: String = "Loading..."
    @Published var counterValue: Int = 0
    private let counter = Counter()
    
    // Async/Await Example: Fetch user data
    func fetchUserData() async {
        do {
            userData = try await simulateNetworkRequest()
        } catch {
            userData = "Failed to fetch data"
        }
    }
    
    // Simulated network call
    private func simulateNetworkRequest() async throws -> String {
        try await Task.sleep(nanoseconds: 2_000_000_000) // Simulating delay
        return "User data fetched successfully!"
    }
    
    // Task Groups Example: Fetch multiple data concurrently
    func fetchMultipleUsers() async {
        await withTaskGroup(of: String.self) { group in
            for i in 1...3 {
                group.addTask { "User \(i) data loaded" }
            }
            for await result in group {
                print(result)
            }
        }
    }
    
    // Structured Concurrency: Parallel execution using async let
        func performOperations() async {
            do {
                async let result1: String = simulateNetworkRequest()
                async let result2: String = simulateNetworkRequest()
                let user1 = try await result1
                let user2 = try await result2
                print(user1, user2)
            } catch {
                print("Error performing operations: \(error)")
            }
        }
    
    // Actor Example: Safely increment shared counter
    func incrementCounter() async {
        await counter.increment()
        counterValue = await counter.getValue()
    }
}

