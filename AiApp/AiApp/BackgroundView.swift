//
//  BackgroundView.swift
//  AiApp
//
//  Created by Nguyen, Sydney on 4/14/25.
//
import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            Image("1st")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            // Example layered content
            VStack(spacing: 20) {
                Text("Welcome!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)

                Text("This is your personalized AI app.")
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

#Preview {
    BackgroundView()
}
