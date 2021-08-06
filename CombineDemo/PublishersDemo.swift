//
//  PublishersDemo.swift
//  CombineDemo
//
//  Created by Dhilip on 02/08/21.
//

import Foundation
import Combine
struct ErrorResponse:Error{
    let errorDescription:String
}
enum TestFailureCondition: Error {
        case exampleFailure
    }
class PublishersDemo {
    var cancellables:Set<AnyCancellable> = Set<AnyCancellable>()
    func justPublihser(){
        let _ = Just("Hello World").map({ param in
            return param.lowercased()
        })
        .sink { param in
            print("\(param)")
        }
    }
    
    func futurePublisher(){

        
        
        func delayedResponse() -> Future<Int,Error>{
            let futurePublisher = Future<Int,Error>{promise in
                let resultValue = Int.random(in: 1...3)
                let resultResponse = Int.random(in: 0...3)
                sleep(UInt32(3))
                print("start")
                if(resultResponse == 0){
                    promise(.failure(ErrorResponse(errorDescription: "error description")))
                }
                else{
                    print("finished \(resultValue)")
                    promise(.success(resultValue))
                }
              
            }
            return futurePublisher
        }
        
        let future = delayedResponse()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+5) {
            future.sink { completion in
                switch completion.self {
                case .failure(let error as ErrorResponse) :
                    print("error \(error.errorDescription)")
                    break
                case .finished:
                    break
                case .failure(_):
                    break
                }
               print("error \(completion)")
            } receiveValue: { result in
                print("result \(result)")
            }.store(in: &self.cancellables)
        }
       

    }
    
    func deferedPublisher(){
        
        struct ErrorResponse:Error{
            let errorDescription:String
        }
        
        func delayedResponse() -> Deferred<AnyPublisher<Int,Error>>{
            return Deferred{
            Future<Int,Error>{promise in
                let resultValue = Int.random(in: 1...3)
                let resultResponse = Int.random(in: 0...3)
                sleep(UInt32(3))
                print("start")
                if(resultResponse == 0){
                    promise(.failure(ErrorResponse(errorDescription: "error description")))
                }
                else{
                    print("finished \(resultValue)")
                    promise(.success(resultValue))
                }
            }.eraseToAnyPublisher()
        }
        }
        let future = delayedResponse()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2) {
            future.sink { completion in
                switch completion.self {
                case .failure(let error as ErrorResponse) :
                    print("error \(error.errorDescription)")
                    break
                case .finished:
                    break
                case .failure(_):
                    break
                }
               print("error \(completion)")
            } receiveValue: { result in
                print("result \(result)")
            }.store(in: &self.cancellables)
        }
        

    }
    
    func emptyPublisher(){
        let empty = Empty<String,Error>(completeImmediately: false).eraseToAnyPublisher()
        empty.sink { completion in
            switch completion{
            case .failure(let error):
            print("error")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func failPublisher(){
        let fail = Fail(outputType: String.self, failure: ErrorResponse(errorDescription: "some error"))
        fail.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func sequencePublisher(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        sequence.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func recordPublisher(){
        
        let array = [1,2,3,4,5]
        let sequence = Record<Int,ErrorResponse> { response in
            response.receive(1)
            response.receive(2)
            response.receive(3)
            response.receive(4)
            //response.receive(ErrorResponse(errorDescription: "error"))
            response.receive(completion: .failure(ErrorResponse(errorDescription: "eee")))
            //response.receive(completion: .finished)
            
        }
        sequence.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func multicastPublisher(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array).multicast {
            PassthroughSubject<Int,ErrorResponse>()
        }
        
        
        sequence.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }.store(in: &cancellables)
        sequence.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }.store(in: &self.cancellables)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+3) {
            sequence.connect().store(in: &self.cancellables)
        }
    }
    
    func scanOperator(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        sequence.scan(0, { a, b in
            print("\(a) and \(b)")
            return b
        })
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func reduceOperator(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        sequence.reduce(0, { a, b in
            print("\(a) and \(b)")
            return b
        })
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func flatMapOperator(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        sequence.flatMap({ value -> AnyPublisher<Int,Never> in
            if(value == 2){
                return Empty<Int,Never>(completeImmediately: true).eraseToAnyPublisher()
            }
            return Just<Int>(value).eraseToAnyPublisher()
        })
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func collectOperator(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        sequence.collect()
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func countOperator(){
        
        let array = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        sequence.count()
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func combineLatest(){
        
        let array = [1,2,3,4,5]
        let array1 = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        let sequence1 = Publishers.Sequence<[Int],ErrorResponse>(sequence:array1)
        Publishers.CombineLatest(sequence,sequence1)
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func mergeLatest(){
        
        let array = [1,2,3,4,5]
        let array1 = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        let sequence1 = Publishers.Sequence<[Int],ErrorResponse>(sequence:array1)
        Publishers.Merge(sequence,sequence1)
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }

    }
    
    func zipLatest(){
        let array = [1,2,3,4,5]
        let array1 = [1,2,3,4,5]
        let sequence = Publishers.Sequence<[Int],ErrorResponse>(sequence:array)
        let sequence1 = Publishers.Sequence<[Int],ErrorResponse>(sequence:array1)
        Publishers.Zip(sequence,sequence1)
            .sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }
    }
    
    func subjectsDemo(){
        let sequence = PassthroughSubject<Int,ErrorResponse>()
        
        sequence.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }.store(in: &cancellables)
        
        sequence.send(10)
      //  sequence.send(completion: .finished)
        sequence.send(completion: .failure(ErrorResponse(errorDescription: "fail error")))
        
        let sequence1 = CurrentValueSubject<Int,ErrorResponse>(5)
        
        sequence1.sink { completion in
            switch completion{
            case .failure(let error):
                print("error \(error.errorDescription)")
            break
            case .finished:
                print("finished")
            }
        } receiveValue: { Result in
            print("result \(Result)")
        }.store(in: &cancellables)
        
        sequence1.send(10)
        sequence.send(completion: .finished)
     //   sequence1.send(completion: .failure(ErrorResponse(errorDescription: "fail error")))
    }
}
