import CreateML
import Foundation

var fileURLs = [URL]()


fileURLs.append(Bundle.main.url(forResource: "1528661786", withExtension: "csv")!)
fileURLs.append(Bundle.main.url(forResource: "1528662392", withExtension: "csv")!)
fileURLs.append(Bundle.main.url(forResource: "1528662491", withExtension: "csv")!)
fileURLs.append(Bundle.main.url(forResource: "1528662601", withExtension: "csv")!)

fileURLs.append(Bundle.main.url(forResource: "1528662965", withExtension: "csv")!)
fileURLs.append(Bundle.main.url(forResource: "1528663782", withExtension: "csv")!)
fileURLs.append(Bundle.main.url(forResource: "1528664890", withExtension: "csv")!)
fileURLs.append(Bundle.main.url(forResource: "1528665611", withExtension: "csv")!)

fileURLs.append(Bundle.main.url(forResource: "1528683220", withExtension: "csv")!)



var table = try MLDataTable(contentsOf: fileURLs[0])
var me = false
for fileURL in fileURLs {
    if me {
        let tempTable = try MLDataTable(contentsOf: fileURL)
        table.append(contentsOf: tempTable)
    }
    me = true
}

table.removeColumn(named: "eyeBlinkLeft")
table.removeColumn(named: "eyeLookDownLeft")
table.removeColumn(named: "eyeLookInLeft")
table.removeColumn(named: "eyeLookOutLeft")
table.removeColumn(named: "eyeLookUpLeft")
table.removeColumn(named: "eyeSquintLeft")
table.removeColumn(named: "eyeWideLeft")
table.removeColumn(named: "eyeBlinkRight")
table.removeColumn(named: "eyeLookDownRight")
table.removeColumn(named: "eyeLookInRight")
table.removeColumn(named: "eyeLookOutRight")
table.removeColumn(named: "eyeLookUpRight")
table.removeColumn(named: "eyeSquintRight")
table.removeColumn(named: "eyeWideRight")
table.removeColumn(named: "browDownLeft")
table.removeColumn(named: "browDownRight")
table.removeColumn(named: "browInnerUp")
table.removeColumn(named: "browOuterUpLeft")
table.removeColumn(named: "browOuterUpRight")
table.removeColumn(named: "cheekPuff")
table.removeColumn(named: "cheekSquintLeft")
table.removeColumn(named: "cheekSquintRight")
table.removeColumn(named: "noseSneerLeft")
table.removeColumn(named: "noseSneerRight")

var tableX = table
var tableY = table

tableX.removeColumn(named: "lookAtPositionY")
tableY.removeColumn(named: "lookAtPositionX")

//let testData = table.randomSplit(by: 0.8, seed: 0)

let regressorX = try MLRegressor(trainingData: tableX, targetColumn: "lookAtPositionX")
let regressorY = try MLRegressor(trainingData: tableY, targetColumn: "lookAtPositionY")


let testFileURL = (Bundle.main.url(forResource: "1528662965", withExtension: "csv")!)
var testTable = try MLDataTable(contentsOf: testFileURL)

let evaluationX = regressorX.evaluation(on: testTable)
let evaluationY = regressorY.evaluation(on: testTable)

//try regressorX.write(to: URL(fileURLWithPath: "/Users/virakri/eye-tracking-ios-prototype/Eyes Tracking Create ML Trainer/regressorMinX.mlmodel"), metadata: nil)
//
//try regressorY.write(to: URL(fileURLWithPath: "/Users/virakri/eye-tracking-ios-prototype/Eyes Tracking Create ML Trainer/regressorMinY.mlmodel"), metadata: nil)


