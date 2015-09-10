//
//  ViewController.swift
//  wirteAndReadFromFileAndTextView
//
//  Created by guitarrkurt on 30/08/15.
//  Copyright (c) 2015 guitarrkurt. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    @IBOutlet weak var labelResult: NSTextField!
    
    //MARK: - Init Automata Propertys
    var alfabetoArray = NSArray()
    var estadosArray  = NSArray()
    var estadoInicialArray = NSArray()
    var estadosFinalesArray = NSArray()
    var tablaTransicion = NSMutableDictionary()
    var expresion = [String]()
    
    //MARK: - Constructor
    override func viewDidLoad() {
        super.viewDidLoad()

        //Read File
        var textFromFile = readFileFromBundle("Automata", typeFile: "txt")
                //Load Propertys Automata
        if textFromFile != ""{
            initAutomata(textFromFile)
        }
        //Evaluar Expresion

        
        //let stdin = NSFileHandle.fileHandleWithStandardInput()
        //let inputString = NSString(data: stdin.availableData, encoding: NSUTF8StringEncoding)
        //println("hola + \(inputString)")
    }

    func readFileFromBundle(var nameFile:String, var typeFile: String) -> String{
        //Read File
        let bundle = NSBundle.mainBundle()
        let path = bundle.pathForResource(nameFile, ofType: typeFile)
        var error: NSError? = NSError()
        var textFromFile = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: &error)
        if textFromFile != nil{
            return textFromFile!
        } else {
            println("\(error)")
            return ""
        }
    }
    
    func initAutomata(textFromFile: String) -> Void{
        //Init Propertys
        var automata: NSArray = textFromFile.componentsSeparatedByString("\n")
        var indexFile =  NSInteger()
        
        //Alfabeto
        indexFile = automata.indexOfObject("Alfabeto:") + 1
        alfabetoArray = automata.objectAtIndex(indexFile).componentsSeparatedByString(",")
        println("alfabetoArray: \(alfabetoArray)")
        
        //Estados
        indexFile = automata.indexOfObject("Estados:") + 1
        estadosArray = automata.objectAtIndex(indexFile).componentsSeparatedByString(",")
        println("estadosArray: \(estadosArray)")
        
        //estadoInicial
        indexFile = automata.indexOfObject("Estado Inicial:") + 1
        estadoInicialArray = automata.objectAtIndex(indexFile).componentsSeparatedByString(",")
        println("estadoInicial: \(estadoInicialArray)")
        
        //estadosFinales
        indexFile = automata.indexOfObject("Estados Finales:") + 1
        estadosFinalesArray = automata.objectAtIndex(indexFile).componentsSeparatedByString(",")
        println("estadosFinales: \(estadosFinalesArray)")
        
        //Matriz de transicion
        var llave = String()
        var object = String()
        var row = NSArray()
        
        indexFile = automata.indexOfObject("Matriz de transicion:") + 1
        for var i=0 ; i < estadosArray.count; ++i, ++indexFile{/*Rows from file*/
            
            row = automata.objectAtIndex(indexFile).componentsSeparatedByString(",")/*from file*/
            println("*** indexFile:\(indexFile) i:\(i) row:\(row)***")
            
            for var j = 0; j < alfabetoArray.count; ++j{/*Columns*/
                
                object = row.objectAtIndex(j) as! String
                llave = "\(i),\(alfabetoArray[j])"
                tablaTransicion.setObject(object, forKey: llave)
                println("object:\(object) forKey:\(llave)")
                
            }
        }
        println("tablaTransicion: \(tablaTransicion)")
    }
    @IBAction func evaluarExpresion(sender: NSButton) {
        //Read Expresion
        if textView.string != ""{
            let cadena: String = textView.string!
            /*correccion*/
            for (index, character) in enumerate(cadena) {
                //do something with the character at index
                println("character: \(character)")
                expresion.append("\(character)")
            }
            println("expresion: \(expresion)")
        } else {
            var txt = "Por favor ingresa una expresion"
            println(txt)
            labelResult.insertText(txt)
        }
        //Comprobar Expresion
        var sera = caracteresExprInAlfabeto(expresion, alfabeto: alfabetoArray as! [String])
        if sera == false {
            var txt = "Ingresaste un caracter que no está en el Alfabeto ⚠️\n" + "Por favor verifica tu expresión !!! 👀"
            println(txt)
            labelResult.placeholderString = txt
        } else {
        
            //Evaluar Estado Inicial - Algoritmo
            
            var llave = String()
            var edo = String()
            var banderaLlegoAFinal = false
            var txt = String()
            
            for var i = 0; i <= expresion.count; ++i{
                println("i vale: \(i)")
                if i == expresion.count{
                    //Llego al final de la expresion
                    for var j = 0; j < estadosFinalesArray.count; ++j{
                        var edoFin = estadosFinalesArray.objectAtIndex(j) as! String
                        println("edoFin: \(edoFin)")
                        println("edo: \(edo)")
                        if edo == edoFin{
                            banderaLlegoAFinal = true
                        }
                    }
                    if banderaLlegoAFinal == true{
                        txt = "Expresion Correcta!! ✅\n" + "Felicidades !!! 😀 👋🏼👋🏼👋🏼"
                        println(txt)
                        labelResult.placeholderString = txt
                    } else {
                        txt = "Expresion Incorrecta!! 🔶\n" + "Aun que tu camino es correcto, no tiene un estado final valido"
                        println(txt)
                        labelResult.placeholderString = txt
                    }
                    break;
                }
                if i == 0{//Edo Inicial
                    llave = "\(estadoInicialArray.objectAtIndex(0)),\(expresion[0])"
                    println("Llave estado inicial: \(llave)")
                } else {
                    llave = "\(edo),\(expresion[i])"
                }
                edo = tablaTransicion.objectForKey(llave) as! String
                println("edo: \(edo)")
                
                if edo != "_" && edo != ""{
                    
                } else {
                    txt = "Expresion Incorrecta!! 🔴\n" + "(\(llave)) no es una transició valida 😔"
                    println(txt)
                    labelResult.placeholderString = txt
                    break;
                }
            }

        
        }
        expresion = []
    }

    func caracteresExprInAlfabeto(expresion: [String], alfabeto: [String]) -> Bool{
        var bandera = false
        for var i = 0; i < expresion.count; ++i{
            for var carAlfa = 0; carAlfa < alfabeto.count; ++carAlfa{
                if expresion[i] == alfabeto[carAlfa]{//Si la expresion dada, es un car del alfabeto
                    bandera = true
                }
            }
            if bandera == true{
                bandera = false
            } else {
                return false
            }
        }
        return true
    }
    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

