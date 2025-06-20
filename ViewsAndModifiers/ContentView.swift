//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Jorge Encinas on 6/20/25.
//

import SwiftUI

struct CapsuleText : View {
    var text: String
    
    var body : some View {
        Text(text)
            .font(.largeTitle)
            .padding()
            //.foregroundStyle(.white)
            .background(.blue)
            .clipShape(.capsule)
    }
}

//Custom modifiers
struct Title: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.white)
            .padding()
            .background(.blue)
            .clipShape(.rect(cornerRadius: 10))
    }
}

// When using custom modifiers, usually you can do this, which
// allows you to use your custom modifier easily.
extension View {
    func titleStyle() -> some View {
        modifier(Title()) //the `return` keyword is implicit here, as we've done before.
    }
}

//Custom modifiers can do much more than just apply other existing modifiers
//  they can also CREATE NEW VIEW STRUCTURE
//  Modifiers return NEW OBJECTS, so we could create one
//      that EMBEDS THE VIEW IN A STACK
//      and adds another View.

struct Watermark : ViewModifier {
    var text : String
    
    func body(content : Content) -> some View {
        ZStack(alignment: .bottomTrailing) {
            content
            Text(text)
                .font(.caption)
                .foregroundStyle(.white)
                .padding(5)
                .background(.black)
        }
    }
}

extension View {
    func watermarked(with text: String) -> some View {
        modifier(Watermark(text: text))
    }
}

// Custom views modifiers
//  can have their own Stored Properties
//  whereas Extensions to View cannot.
//  So it might be better to add a Custom View Modifier vs a New Method to View.

// CUSTOM CONTAINERS --------------------
struct GridStack<Content : View> : View { //Provide any content that conforms to View. `: View` means this also conforms to View
    let rows : Int
    let columns : Int
    @ViewBuilder let content: (Int, Int) -> Content
    
    var body : some View {
        VStack {
            ForEach(0..<rows, id: \.self) { (row : Int) in
                HStack {
                    ForEach(0..<columns, id: \.self) { (column : Int) in
                        content(row, column)
                    }
                }
            }
        }
    }
    
}

struct TitleBlueFont : ViewModifier {
    func body(content : Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundStyle(.blue)
            .fontWeight(.bold)
            .padding()
    }
}

extension View {
    func titleBlueFont() -> some View {
        modifier(TitleBlueFont())
    }
}

struct ContentView: View {
    
    var body: some View {
        Text("Prominent Title")
            .titleBlueFont()
        GridStack(rows: 4, columns: 4) { (row : Int, col: Int) in
            //HStack { //@ViewBuilder let us remove this!
            Image(systemName: "\(row * 4 + col).circle")
            Text("R\(row) C\(col)")
            //}
        }
        VStack(spacing: 10) {
            Color.blue
                .frame(width: 300, height: 200)
                .watermarked(with: "Hacking with Swift (Paul)")
            Text("Hello world")
                .titleStyle() //Works wonders.
                //.modifier(Title()) //Applies our vustom modifier!
            CapsuleText(text: "First")
                .foregroundStyle(.white)
            CapsuleText(text: "Second")
                .foregroundStyle(.yellow) //Does no change, unless you remove foregroundStyle from the struct
        }
        
    }
}

// Why structs over classes?
//  Originally it used classes, rather than structs.

// 1. Performance
//      structs are simpler and faster than classes.
//  This is just a part of it, though
//  in UIKit, every view descended from a class called
//  `UIView`, that had many properties and methods.
//      - Background color
//      - Constraints that determined position
//      - A layer for rendering its contents into
//      - ... more
//  There were a lot of these, and every UIView, and UIView Subclass, had to have them, since
//  that's how inheritance works.

// On the other hand, in SwiftUI all of our views are trivial structs, almost free to create.
// No extra values inherited.

//  1000 integers, or 100k integers, or 1000 SwiftUI views, or 100k SwiftUI views.
//  They are so fast now, it doesn't matter.

//  2. Isolating State, ingrained in its Design
//      since classes are able to change their values freely, it can lead to messier code
//  On the other hand, views that don't mutate over time, then we must thing from a more
//      functional design approach
//      Views are simple, inert things that convert data into UI, a bit more rigid but controlled
//  Color.red, LinearGradient, both are views.
//  In comparison, UIView has around 200 properties and methods, all passed to its subclasses.

// In summary, stick to `struct`s

// UIHostingController
//  bridge betwen UIKit and SwiftUI
//  the thing behind our ContentView
// If you modify it, you'll find your code no longer works for other Apple platforms
//  in fact, it might start working entirely on iOS in the future.

// Believe that there's nothing behind our view. What you see is what there is.
// Starting from there, the solution to our predicament is...
// Make the VStack take more space

//maxwidth / maxHeight doesn't mean it MUST take that space, but only that it can.
//  SwiftUI will make sure other views have enough space, if they're around with this one.


// MODIFIER ORDER MATTERS
//  when applying a modifier, we create a NEW VIEW
//  with that change applied
//  Our views only hold THE EXACT PROPERTIES we give them
//      we don't just modify the existing view in place.
//      so if we set the background color or font size, there is no place to store that data.

// Button("Hello, world!") {
//
// }
// .background(.red)
// .frame(width: 200, height: 200)

// Each modifier creates a NEW STRUCT with that modifier applied
// rather than just setting a property on the view.

// ModifiedContent<ModifiedContent<Button<Text>, _BackgroundStyleModifier<Color>>, _FrameLayout>

// ModifiedContent<OurThing, OurModifier>
//  when you keep applying, these just pile up
//      ModifiedContent<ModifiedContent<...
//  So to read, start from the innermost type, and work your way out.

//  ModifiedContent<Button<Text>, _BackgroundStyleModifier<Color>
//  ModifiedContent<..., _FrameLayout> //Takes our first view, a button + backgroundColor
//      and gives it a larger frame.

// Thus, the order of your modifiers matters.

//  An important side effect of using modifiers is that we can apply the same effect multiple times
//  each one simply adds to whatever was there before.

//  For example, the padding modifier

// SOME VIEW ----------------------
//  Opaque Return Types, seen here in `some View`
//  It means our object conforms to the View protocol, but we don't want to specify what

//  We may not know the view type, but the compiler does
//  1. Performance
//      SwiftUI needs to understand how the views change to update the interface
//      It would be slow if it had to figure out what exactly changed.
//  2. The way SwiftUI builds up its data using `ModifiedContent`
//      Remember the button printed instances of `ModifiedContent`
//      we printed its exact swift type
//      Well, the `View` PROTOCOL has an ASSOCIATED TYPE attached to it.
//      We would not be able to just return a `View` object (or struct, whatever)

//      var body: View {} would not work
//      var body : Text {} does work
//      That's because a View expects to have some type of view within it!
//      `View` has a slot that must be filled with some View.

//      `some View` lets us say,
//      This will be a Button, or a Text, but we can't say exactly what.

// SOME VIEW - COMPLICATIONS
//  1. How does VStack work? "What kind of content does it have" slot must be filled
//      A: Behind the scenes Swift creates a `TupleView`,
//          it just keeps expanding how many items it has.
//  2. What happens if we send back two views directly from our `body` property,
//  without wrapping them in a Stack?
//      A: Swift silently applies a special attribute to the `body` property
//          called `@ViewBuilder`.
//          It silently wraps multiple views in those `TupleView` containers
//          So that even though it looks like we're sending back multiple views,
//          they get combined into one `TupleView`

//      Right-click on View and choose "Jump to Definition", you'll see that the `body` property is required,
// AND that it's marked with the @ViewBuilder attribute.

//      @ViewBuilder @MainActor var body: Self.Body { get }

// CONDITIONAL MODIFIERS -------------------
//  You may want some modifiers to apply ONLY when a condition is met.
//  In Swift, the TERNARY CONDITIONAL OPERATOR is the easiest way to do that.

// ENVIRONMENT MODIFIERS -------------------
//  Modifiers can be applied to CONTAINERS
//  which allows us to apply the same modifier to MANY VIEWS AT THE SAME TIME.

// If any child override that modifier, the child's version takes precedence!

// Regular Modifiers on Child views
//  BLURS applied to Child Views are ADDED to the VStack, rather than replacing it
//  that's why it doesn't work.

// VIEWS AS PROPERTIES ---------------------
//  Complex view hierarchies in SwiftUI
//  can be managed a bit by using PROPERTIES.
//      Create a View as a Property of your own View
//      then use that property inside your Layouts.

// HOWEVER, creating one stored property that refers to OTHER stored propeties IS NOT POSSIBLE
//  So a TextField bound to a local property will cause problems.

// BUT, you can create COMPUTED PROPERTIES

#Preview {
    ContentView()
}
