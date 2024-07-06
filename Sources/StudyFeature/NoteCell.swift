import CommonUI
import Models
import SwiftUI

public struct NoteCell: View {
    let note: Note
    let goToAddWordButtonTapped: () -> Void = {}
    let studyButtonTapped: () -> Void = {}
    
    public var body: some View {
        Rectangle()
            .fill(.white)
            .cornerRadius(12)
            .border(.gray5, 12)
            .frame(height: 120)
            .overlay {
                HStack {
                    note.noteColor
                        .frame(width: 10)
                        .cornerRadius(12, corners: [.topLeft, .bottomLeft])
                    VStack(alignment: .leading) {
                        Text(note.noteCategory)
                            .font(.caption2)
                            .textColor(.gray3)
                            .padding(.all, 4)
                            .border(note.noteColor)
                        Spacer()
                        Text(note.noteName)
                            .textStyler(font: .callout,
                                        weight: .semibold)
                        Spacer()
                        CellBottomView()
                    }
                    .overlay(alignment: .topTrailing) {
                        ButtonView()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 10)
                    
                    Spacer()
                }
            }
    }
    
    @ViewBuilder
    private func ButtonView() -> some View {
            if note.repeatCount >= 4 {
                Image.goodIcon
                    .resizable()
                    .frame(width: 44, height: 44)
            } else if !note.wordList.isEmpty {
                Button(
                    action: {
                        studyButtonTapped()
                    }, label: {
                        VStack(spacing: 4) {
                            Image(systemName: "play.circle")
                            Text("학습 시작")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .frame(width: 44, height: 44)
                        .background(note.noteColor)
                        .cornerRadius(2)
                    }
                )
                .buttonStyle(PlainButtonStyle())
            }
    }
    
    @ViewBuilder
    private func CellBottomView() -> some View {
        Group {
            if note.wordList.isEmpty {
                MainButton(title: "단어 등록하러 가기",
                           backgroundColor: note.noteColor) {
                    goToAddWordButtonTapped()
                }
            } else {
                RepeatCountView()
            }
        }
        .frame(height: 24)
    }
    
    private func RepeatCountView() -> some View {
        ZStack {
            StudyProgressBar()
                .overlay {
                    HStack {
                        ForEach(1...4, id: \.self) { idx in
                            NumberCircle(idx: idx)
                            if idx != 4 {
                                Spacer()
                            }
                        }
                    }
                }
        }
    }
    
    private func StudyProgressBar() -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray5)
                Rectangle()
                    .fill(note.noteColor)
                    .frame(width: geo.size.width * progressBarWidth)
            }
        }
        .frame(height: 6)
    }
    
    // 학습 횟수에 따른 프로그래스바 길이 매칭
    private var progressBarWidth: CGFloat {
        switch note.repeatCount {
        case 0, 1:
            return 0.0
        case 2:
            return 0.35
        case 3:
            return 0.7
        default:
            return 1
        }
    }
    
    @ViewBuilder
    private func NumberCircle(idx: Int) -> some View {
        if note.repeatCount < idx {
            Text(idx.description)
                .textStyler(color: .white,
                            font: .body,
                            weight: .bold)
                .background {
                    Circle()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.gray5)
                }
        } else if idx == 1 {
            ImageView(getTestResultImage(note.firstTestResult))
        } else if idx == 4 {
            ImageView(getTestResultImage(note.lastTestResult))
        } else {
            ImageView(.checkmark)
        }
    }
    
    private func getTestResultImage(_ result: Double) -> Image {
        if result > 0 && result <= 0.5 {
            .badFace
        } else if result > 0.5 && result <= 0.8 {
            .normalFace
        } else {
            .goodFace
        }
    }
    
    private func ImageView(_ image: Image) -> some View {
            image
                .resizable()
                .frame(width: 20, height: 20)
                .background{
                    Circle()
                        .frame(width: 24, height: 24)
                        .foregroundStyle(note.noteColor)
                }
    }
}

#Preview {
    VStack {
        NoteCell(note: .mock)
        NoteCell(note: .mock2)
    }
    .padding(.horizontal, 16)
}
