import Foundation
import PromiseSwift

enum CustomError: Error {
    case emptyError
}

class Network {
    var url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    func post() -> Promise<Data> {
        return Promise(queue: .global()) { (resolve) in
            var request = URLRequest(url: self.url)
            request.httpMethod = HTTPMethod.post.rawValue
            
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                guard let data = data else {
                    resolve(.error(error ?? CustomError.emptyError))
                    return
                }
                resolve(.value(data))
            }
            
            task.resume()
        }
    }
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
    case head = "HEAD"
}
