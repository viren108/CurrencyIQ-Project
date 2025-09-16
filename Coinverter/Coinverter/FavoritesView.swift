import SwiftUI
import FirebaseFirestore

struct FavoritesView: View {
    @State private var favorites: [FavoriteCurrencyPair] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(favorites) { favorite in
                    HStack {
                        Text("\(favorite.baseCurrency) to \(favorite.targetCurrency)")
                        Spacer()
                        Button(action: {
                            removeFavorite(favorite: favorite)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onDelete(perform: deleteFavorites)
            }
            .navigationTitle("Favorite Currency Pairs")
            .onAppear {
                fetchFavorites()
            }
        }
    }

    func fetchFavorites() {
        let db = Firestore.firestore()
        db.collection("favorites").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching favorites: \(error)")
                return
            }
            favorites = querySnapshot?.documents.compactMap { document in
                let data = document.data()
                let baseCurrency = data["baseCurrency"] as? String ?? ""
                let targetCurrency = data["targetCurrency"] as? String ?? ""
                return FavoriteCurrencyPair(baseCurrency: baseCurrency, targetCurrency: targetCurrency)
            } ?? []
        }
    }

    func removeFavorite(favorite: FavoriteCurrencyPair) {
        let db = Firestore.firestore()
        db.collection("favorites").whereField("baseCurrency", isEqualTo: favorite.baseCurrency)
            .whereField("targetCurrency", isEqualTo: favorite.targetCurrency)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error finding favorite to delete: \(error)")
                    return
                }
                for document in querySnapshot!.documents {
                    db.collection("favorites").document(document.documentID).delete { error in
                        if let error = error {
                            print("Error deleting favorite: \(error)")
                        } else {
                            favorites.removeAll { $0.id == favorite.id }
                        }
                    }
                }
            }
    }

    func deleteFavorites(at offsets: IndexSet) {
        for index in offsets {
            let favorite = favorites[index]
            removeFavorite(favorite: favorite)
        }
    }
}

#Preview {
    FavoritesView()
}
