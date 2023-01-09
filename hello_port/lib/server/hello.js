require('node_erlastic').server(function(term,from,current_amount,done){
    if (term == "hello") return done("reply","Hello world !");
    if (term == "what") return done("reply","What what ?");
    if (term == "kbrw") return done("reply", current_amount - (Math.floor(Math.random() * (current_amount - 0)) + 0))
    if (term[0] == "kbrw") return done("noreply", current_amount+term[1]);
    throw new Error("unexpected request")
  });