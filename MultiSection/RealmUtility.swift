import Realm

extension RLMResults {
    var allObjects: [RLMObject] {
        var objs = [RLMObject]()
        for i in 0..<self.count {
            if let obj = self.object(at: i) as? RLMObject {
                objs.append(obj)
            }
        }
        return objs
    }
}
