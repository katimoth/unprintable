import SwiftUI

/// Display a user's accuracy and other playing statistics from a guitar lesson
///
/// After a guitar lesson is completed, this view will be overlayed onto the UI
/// by `GuitarLessonView`
struct ResultsView: View {
    @ObservedObject var audioPlayer: AudioPlayer

    let totalNumChords: Double

    /// The width of the circular progress bar's stroke, not the entire bar
    let progressBarWidth = 20.0
    var body: some View {
        VStack {
            Text("Results")
                .font(Font.h1)
                .foregroundColor(Color.floral_white)
            
            // Circular progress bar
            ZStack {
                let accuracy = Double(audioPlayer.correctChordsPlayed) / totalNumChords

                // "Outline" of the progress bar
                Circle()
                    .stroke(lineWidth: progressBarWidth)
                    .foregroundColor(Color.pearl_aqua_tint_80)
                // "Fill" of the progress bar
                Circle()
                    .trim(
                        from: 0.0,
                        to: CGFloat(accuracy)
                    )
                    .stroke(style: StrokeStyle(
                        lineWidth: progressBarWidth,
                        lineCap: .round,
                        lineJoin: .round
                    ))
                    .foregroundColor(Color.pearl_aqua)
                    // By default, the circle will be drawn starting from 3
                    // o'clock. Rotate this circle such that we start drawing
                    // from 12 o'clock
                    .rotationEffect(Angle(degrees: 270.0))
                
                HStack(alignment: .top, spacing: 0) {
                    // Choosing to round down because don't want to round to
                    // 100% if user did not truly get 100% but got, say, 99.9%
                    Text(String(Int(accuracy * 100)))
                        .font(Font.custom(Font.comfortaa_regular, size: 60))
                        .bold()
                    Text("%")
                        .font(Font.custom(Font.comfortaa_regular, size: 40))
                        .bold()
                }
            }
                .frame(width: 200.0, height: 200.0)
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.black.opacity(0.80))
    }
}
