import {Sampler, Transport, Part, Time} from 'tone';
import StartAudioContext from 'startaudiocontext';
import svg2pdf from 'svg2pdf.js';
import jsPDF from 'jspdf-yworks';
import abcjs from "abcjs";

import Elm from './Main.elm';

const root = document.getElementById('root');
const app = Elm.Main.embed(root);

var sampler = null;
var part = null;


var button = document.getElementById('play-button');

StartAudioContext(Transport.context, button, function(){
});

app.ports.downloadPdf.subscribe(function() {
  const svgElement = document.getElementById('score').lastChild;
  const width = 600, height = 400;

  // create a new jsPDF instance
  const pdf = new jsPDF('l', 'pt', [width, height]);

  // render the svg element
  svg2pdf(svgElement, pdf, {
    xOffset: 0,
    yOffset: 0,
    scale: 1
  });

  // or simply safe the created pdf
  pdf.save('luigi-score.pdf');
});

app.ports.renderScore.subscribe(function(input) {
  const elementId = input[0];
  const score = input[1];
  abcjs.renderAbc(elementId, score);
});


app.ports.loadSamples.subscribe(function(pitchToSampleUrlMapping){
  const toObj = (array) =>
     array.reduce((obj, item) => {
       obj[item[0]] = item[1]
       return obj
     }, {});

  sampler = new Sampler(toObj(pitchToSampleUrlMapping), function() {
    app.ports.samplesLoaded.send(null);
  } ).toMaster();
});

app.ports.startSequence.subscribe(function(data){
  Transport.timeSignature = data.timeSignature;
  Transport.bpm.value = 140;
  Transport.loop = true;
  Transport.loopEnd = data.loopEnd;

  part = new Part(function(time, note){
    sampler.triggerAttackRelease(note, data.noteLength, time);
  }, data.notes);

  part.start(0);
  Transport.start("+0.1");
});

app.ports.stopSequence.subscribe(function(){
  Transport.stop()
  if (part != null)  {
    part.removeAll();
    part = null;
  };
});
