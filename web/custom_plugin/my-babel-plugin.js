module.exports = function (babel) {
    const { types: t } = babel;
    
    return {
        visitor: {
            JSXElement(path){
                if(path.node.openingElement.name.name == "Declaration"){
                    if(t.isJSXExpressionContainer(path.node.openingElement.attributes[1].value)){
                        let element = t.variableDeclaration(
                            "var"
                            ,[
                            t.variableDeclarator(
                                t.identifier(path.node.openingElement.attributes[0].value.value), 
                                path.node.openingElement.attributes[1].value.expression
                                )
                              ]
                          )
                        path.parentPath.replaceWith(element)
                    } else {
                        let element = t.variableDeclaration(
                            "var"
                            ,[
                            t.variableDeclarator(
                                t.identifier(path.node.openingElement.attributes[0].value.value), 
                                path.node.openingElement.attributes[1].value
                                )
                              ]
                          )
                        path.parentPath.replaceWith(element)
            
                    }                                 
                }
                
            }
        }
    };
}