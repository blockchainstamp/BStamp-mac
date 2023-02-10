//
//  StampDetails.swift
//  BStamp
//
//  Created by wesley on 2023/2/10.
//

import SwiftUI

struct StampDetailsView: View {
        @Environment(\.managedObjectContext) private var viewContext
        @State var selection:CoreData_Stamp
        var body: some View {
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
}

struct StampDetails_Previews: PreviewProvider {
        static var previews: some View {
                StampDetailsView(selection: CoreData_Stamp(context: PersistenceController.shared.container.viewContext))
        }
}
