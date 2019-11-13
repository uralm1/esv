// tune numeral
numeral.register('locale','ru',{
  delimiters: {thousands: ' ',decimal: ','},
  //not full, huh
});
numeral.locale('ru');
numeral.nullFormat('н/д');

// v0.9 rewritten with Numeral.js
function floattext(v){
  return numeral(v).format('0,0')
}

//id mapping with cache
function idmapper(c,xxx){
  var lc = c;
  var lxxx = String(xxx);
  var ch = {};

  function m2id(m){
    if(ch[m]===undefined) {ch[m]=lc+Base64.encodeURI(lxxx+m);}
    return ch[m]
  }

  return {
    zfloat: function(m){
      var sv=$('#'+m2id(m)).val().trim().replace(' ','').replace(',','.');
      var v=parseFloat(sv);if(isNaN(v)){v=0}
      return v
    },
    zint: function(m){
      var sv=$('#'+m2id(m)).val().trim().replace(' ','');
      var v=parseInt(sv);if(isNaN(v)){v=0}
      return v
    }
  }
}
