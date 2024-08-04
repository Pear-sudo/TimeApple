//
//  TagView.swift
//  Time
//
//  Created by A on 03/08/2024.
//

import SwiftUI
import SwiftData
import Collections
import Combine

struct TagSelector: View {
    
    @Environment(\.modelContext) private var context
        
    @State private var tagText: String = ""
    @Bindable private var share = Share()
    
    @FocusState private var focusIndex: Int?
    @StateObject private var eventPublisher = EventPublisher()
            
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 0) {
                ForEach(Array(share.selectedTags.enumerated()), id: \.offset) { index, tag in
                    TagInput(index: index, focusIndex: $focusIndex, tagText: $tagText, commands: $share.commands, selectedTags: $share.selectedTags)
                        .fixedSize()
                    CompactTagView(tag: tag)
                }
                TagInput(index: -1, focusIndex: $focusIndex, tagText: $tagText, commands: $share.commands, selectedTags: $share.selectedTags)
            }
            .padding(.vertical, 3)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            TagList(tagText: tagText, commands: $share.commands, selectedTags: $share.selectedTags)
                .clipShape(RoundedRectangle(cornerRadius: 5))
        }
        .background(KeyEventHandlingView(eventPublisher: eventPublisher))
        .onReceive(eventPublisher.$deletePressed) { _ in
            guard var index = focusIndex, !share.selectedTags.isEmpty else {
                return
            }
            if index == -1 {
                index = share.selectedTags.count
            }
            index -= 1
            if index < 0 || index >= share.selectedTags.count {
                return
            }
            share.selectedTags.remove(at: index)
            var newFocus = index
            if newFocus < 0 {
                newFocus = 0
            }
            if newFocus == share.selectedTags.count {
                newFocus = -1
            }
            focusIndex = newFocus
        }
    }
}

struct TagList: View {
    @Environment(\.modelContext) private var context
    
    @Query private var tags: [Tag]
    
    @State private var selectedId = Set<String>()
    @State private var position: Int = -1
    
    @Binding private var commands: Deque<KeyEquivalent>
    @Binding private var selectedTags: [Tag]
        
    private var tagText: String = ""
    
    init(tagText: String, commands: Binding<Deque<KeyEquivalent>>, selectedTags: Binding<[Tag]>) {
        self.tagText = tagText
        self._commands = commands
        self._selectedTags = selectedTags
        
        let predicate = #Predicate<Tag> { tag in
            return tagText.isEmpty ? true : tag.name.localizedStandardContains(tagText)
        }
        self._tags = Query(filter: predicate, animation: .default)
    }
    
    var body: some View {
        ScrollViewReader { reader in
            List(selection: $selectedId) {
                if !tagText.isEmpty && tags.isEmpty {
                    Text("Create new tag \"\(tagText)\"")
                        .tag(tagText)
                        .onTapGesture(perform: createTag)
                }
                ForEach(tags, id: \.name) { tag in
                    if !selectedTags.contains(tag) {
                        TagView(tag: tag)
                            .onTapGesture {
                                selectTag(tag)
                            }
                            .id(tag.name)
                    }
                }
            }
            .onKeyPress(keys: [.tab, .return], action: {_ in selectSelectedTag(); return .handled})
            .onChange(of: tagText) {
                position = -1
                selectedId.removeAll()
            }
            .onChange(of: commands) {
                guard let command = commands.popFirst() else {
                    return
                }
                switch command {
                case .return, .tab:
                    guard selectedId.isEmpty else {
                        selectSelectedTag()
                        return
                    }
                    if tags.isEmpty {
                        createTag()
                        return
                    }
                    if let count = try? context.fetchCount(FetchDescriptor(predicate: #Predicate<Tag> {$0.name == tagText})), count == 0 {
                        createTag()
                        return
                    }
                case .downArrow, .upArrow:
                    let visibleTags = visibleTags
                    position = command == .downArrow ? position + 1 : position - 1
                    if position >= visibleTags.count {
                        position = visibleTags.count - 1
                    }
                    if position < 0 {
                        position = 0
                    }
                    let selected = visibleTags[position]
                    selectedId = [selected.name]
                    reader.scrollTo(selected.name)
                    return
                default:
                    return
                }
            }
        }
    }
    
    private var visibleTags: [Tag] {
        return tags.filter({!selectedTags.contains($0)})
    }
    
    private func createTag() {
        let newTag = Tag(name: tagText)
        context.insert(newTag)
    }
    
    private func selectSelectedTag() {
        let predicate = #Predicate<Tag> {selectedId.contains($0.name)}
        let descriptor = FetchDescriptor(predicate: predicate)
        if let tags = try? context.fetch(descriptor) {
            selectedTags.append(contentsOf: tags)
            selectedId.removeAll()
        }
    }
    
    private func selectTag(_ tag: Tag) {
        selectedTags.append(tag)
        selectedId.removeAll()
    }
}

struct TagView: View {
    var tag: Tag
    var body: some View {
        Text(tag.name)
    }
}

struct CompactTagView: View {
    var tag: Tag
    var body: some View {
        Text(tag.name)
            .padding(.horizontal, 5)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .onHover { hover in
                if hover {
                    NSCursor.arrow.push()
                } else {
                    NSCursor.pop()
                }
            }
    }
}

struct TagInput: View {
    var index: Int
    @FocusState.Binding var focusIndex: Int?
    @Binding var tagText: String
    @Binding var commands: Deque<KeyEquivalent>
    @Binding var selectedTags: [Tag]
        
    var body: some View {
        TextField("", text: isFocused ? $tagText : .constant(""))
            .textFieldStyle(.plain)
            .multilineTextAlignment(textAlignment)
            .padding(.horizontal, padding)
            .onKeyPress(keys: [.tab, .upArrow, .downArrow]) { keyPress in
                commands.append(keyPress.key)
                return .handled
            }
            .onKeyPress(keys: [.leftArrow, .rightArrow], action: handleLeftRightArrow)
            .focused($focusIndex, equals: index)
            .onSubmit {
                commands.append(.return)
            }
            .onChange(of: focusIndex) {
                tagText = ""
            }
    }
    
    private var isFocused: Bool {
        focusIndex == index
    }
    
    private func handleLeftRightArrow(_ keyPress: KeyPress) -> KeyPress.Result {
        let key = keyPress.key
        
        var newFocusIndex = index
        if newFocusIndex == -1 {
            newFocusIndex = selectedTags.count
        }
        
        switch key {
        case .leftArrow:
            newFocusIndex -= 1
        case .rightArrow:
            newFocusIndex += 1
        default:
            break
        }
        
        if newFocusIndex < 0 {
            newFocusIndex = 0
        }
        if newFocusIndex >= selectedTags.count {
            newFocusIndex = -1
        }
        
        focusIndex = newFocusIndex
        
        return .handled
    }
    
    private var textAlignment: TextAlignment {
        if index < 0 {
            // end
            return .leading
        }
        if index == 0 {
            // begin
            return .trailing
        }
        return .center
    }
    
    private var padding: CGFloat {
        guard !selectedTags.isEmpty else {
            return 3
        }
        switch textAlignment {
        case .leading:
            return 0
        case .center:
            return -3
        case .trailing:
            return 0
        }
    }
}

class EventPublisher: ObservableObject {
    @Published var deletePressed: Bool = false
}

struct KeyEventHandlingView: NSViewRepresentable {
    @ObservedObject var eventPublisher: EventPublisher
    
    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 51 { // 51 is the keyCode for delete/backspace
                eventPublisher.deletePressed.toggle()
            }
            return event
        }
        context.coordinator.monitor = monitor
        return view
    }
    
    func updateNSView(_ nsView: NSView, context: Context) {}
    
    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        if let monitor = coordinator.monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator {
        var monitor: Any?
    }
}

@Observable class Share {
    var commands: Deque<KeyEquivalent> = []
    var selectedTags: [Tag] = []
}

#Preview {
    TagSelector()
        .padding()
        .modelContainer(for: models, inMemory: false)
}
