//
//  ContentView.swift
//  ViewsAndModifiers
//
//  Created by Jorge Encinas on 6/20/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Hello, World!") {
                print(type(of: self.body))
            }
                .frame(width:200, height:200)
                .background(.red)
            
            Text("Hello World!")
                .padding()
                .background(.red)
                .padding()
                .background(.blue)
                .padding()
                .background(.green)
                .padding()
                .background(.yellow)
                
        }
        
        //.frame(maxWidth:.infinity, maxHeight:.infinity) //Notice that the order matters!
        //.background(.red)
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
#Preview {
    ContentView()
}
