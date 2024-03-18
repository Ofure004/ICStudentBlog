import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Result "mo:base/Result";
import Array "mo:base/Array";
import Iter "mo:base/Iter";

actor Blog{
    type Content = {
      #text: Text;
      #image: Blob;
      #video: Blob;
    };

    type Message = {
      vote: Int;
      content: Content;
      creator: Principal;
    };


    stable var messageID: Nat = 0;
    var wall = HashMap.HashMap<Nat,Message>(0, Nat.equal, Hash.hash);


    public shared(msg) func writeMessage (c:Content) : async Nat {
      let message : Message = {
        vote = 0;
        content: Content = c;
        creator = msg.caller;
      };

      messageID := messageID +1;
      wall.put(messageID, message);

      return messageID;
    };

    public query func getMessage (msgID: Nat) : async Result.Result<Message, Text> {
          var result = wall.get(msgID);

          switch (result){
            case(?result){
              return #ok result;
            };
            case(null){
              return #err "No message found"
            }
          }
    };

    public shared(msg) func updateMessage(msgID:Nat, c:Content): async Result.Result<(), Text>{
      var result = wall.get(msgID);
      switch (result){
            case(?result){
               if(msg.caller == result.creator){
                 let msg : Message = {
                    vote = result.vote;
                    content= c;
                    creator = result.creator;
                 };
                 wall.put(msgID,msg);
                return #ok;
               } else{
                 return #err "caller not creator"
               }
            };
            case(null){
              return #err "No message found to update"
            }
          }
    };

    public shared func deleteMessage(msgID:Nat) : async Result.Result<(), Text>{
       var result = wall.get(msgID);
          switch (result){
            case(?result){
              wall.delete(msgID);
              return #ok;
            };
            case(null){
              return #err "No message found"
            }
          }
    };

    public shared func upVote(msgID:Nat): async Result.Result<(), Text>{
      var result = wall.get(msgID);

          switch (result){
            case(?result){
              let msg : Message = {
                    vote = result.vote + 1;
                    content= result.content;
                    creator = result.creator;
                 };
                 wall.put(msgID,msg);
              return #ok;
            };
            case(null){
              return #err "No message found"
            }
          }
    };

    public shared func downVote(msgID:Nat) : async Result.Result<(),Text>{
      var result = wall.get(msgID);

          switch (result){
            case(?result){
              let msg : Message = {
                    vote = result.vote - 1;
                    content= result.content;
                    creator = result.creator;
                 };
                 wall.put(msgID,msg);
              return #ok;
            };
            case(null){
              return #err "No message found"
            }
          }
    };
    public query func getAllMessages() : async [Message]{
      let msgs:[Message] = Iter.toArray(wall.vals());
      // for (value in ()){
      //   msgs.append(msgs,value)
      // }
      return msgs;
    };

};