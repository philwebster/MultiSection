import Realm

class Group: RLMObject {
    @objc dynamic var name: String = ""
    @objc dynamic var isOwned: Bool = false
    @objc dynamic var isOrganization: Bool = false
    @objc dynamic var isFavorite: Bool = false
}
