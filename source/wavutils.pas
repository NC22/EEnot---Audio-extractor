unit wavutils;

interface

uses classes, sysutils, common_base_types;

// ��������� �������� ������� http://audiocoding.ru/article/2008/05/22/wav-file-structure.html
// http://microsin.ru/content/view/1197/44/
// ������ ������������� http://audiocoding.ru/assets/meta/2008-05-22-wav-file-structure/wav_formats.txt

type

  // universal wav header for PCM \ no-PCM data: mu-law (u-law) and A-law / float data
  // �� ������������ pcm ��� ����� fact, ���������� ���� �� ���������
    
  TNoPcmWaveHeader = packed record
    chIdRiff: array [0..3] of AnsiChar; // 4 �����, ������� �RIFF�
    chSizeRiff: longint; // 4 �����, ������ ������ : ������ ���� �������� ������ - chIdRiff-chSizeRiff
 
        waveId: array [0..3] of AnsiChar; // 4 �����, ������� �WAVE�
  
        chIdFmt: array [0..3] of AnsiChar; // 4 �����, ������� �fmt �
        chSizeFmt: longint; // 4 �����, ������ ������ : 18

            wFormatTag: smallint; // 2 �����, ����� ������
            nChannels: smallint; // 2 �����, ���-�� ������� 1 - ����, 2 - ������ - Nc
            nSamplesPerSec: longint;  // 4 �����, ������� �������������. 8000 ��, 44100 �� � �.� - F
            nAvgBytesPerSec: longint; // 4 �����, ���������� ����, ���������� �� ������� ��������������� (F * M * Nc)
            nBlockAlign: smallint;  // 2 �����, ���������� ���� ��� ������ ������, ������� ��� ������. (Nc * M)
            wBitsPerSample: smallint; // 2 �����, ���������� ��� � ������. 8 ���, 16 ��� � �.�. M*8 M = wBitsPerSample div 8 - � ������

            cdSize : smallint; // 2 �����, ������ ����������
        
        chIdFact: array[0..3] of AnsiChar; // 4 �����, ������� "fact"
        chSizeFact: longint; // 4 �����, ������ ������ : 4
            dwSampleLength: longint; // SampleCount * nChannels
        
        cdIdData: array [0..3] of AnsiChar;
        chSizeData: longint; // SampleCount * M * nChannels;    
  end;


function CreateNoPcmWaveHeader(DataLen, PadByte, SamplesPerSec: integer;
  BitsPerSample, Channeles, Format: smallint; var WaveHeader: TNoPcmWaveHeader) : boolean;
function ValidateNoPcmWaveHeader(var WaveHeader: TNoPcmWaveHeader) : boolean;
function GetWaveTime(var WaveHeader: TNoPcmWaveHeader) : double;

implementation

// ������������� ��������� ��� ������ �������������

function CreateNoPcmWaveHeader(DataLen, PadByte, SamplesPerSec: integer;
  BitsPerSample, Channeles, Format: smallint; var WaveHeader: TNoPcmWaveHeader) : boolean;
var 
    sBytesLong : smallint;
begin
	Result := true;
  if (not BitsPerSample in [8, 16]) or
     (not Channeles in [1, 2])
    then begin
		Result := false;
		Exit;
	end;

    sBytesLong := BitsPerSample div 8;
    // DataLen - SampleCount * sBytesLong * Channeles;
    
  with WaveHeader do begin
    chIdRiff := 'RIFF';
    chSizeRiff := DataLen + sizeof(TNoPcmWaveHeader)-8 + PadByte;
    waveId := 'WAVE';
    chIdFmt := 'fmt ';
    chSizeFmt := 18;
    wFormatTag := Format;
    nChannels := Channeles;
    nSamplesPerSec := SamplesPerSec;
    nAvgBytesPerSec := SamplesPerSec * sBytesLong * Channeles;
    nBlockAlign := Channeles * sBytesLong;
    wBitsPerSample := BitsPerSample;
    cdSize := 0;
    
    chIdFact := 'fact';
    chSizeFact := 4;

    dwSampleLength := DataLen div (sBytesLong * Channeles);
    
    cdIdData := 'data';
    chSizeData := DataLen;

    // attempt to add info according to spec formats. not work properly need more specification info
    {if wFormatTag = $0011 then begin
             nBlockAlign := (1 + 1) * BitsPerSample * nChannels;
            // nSamplesPerBlock := (((nBlockAlign - (7 * nChannels)) * 8) / (wBitsPerSample * nChannels)) + 2;
             nAvgBytesPerSec := ((nSamplesperSec / nSamplesPerBlock) * nBlockAlign);
    end; }
  end;
end;

function ValidateNoPcmWaveHeader(var WaveHeader: TNoPcmWaveHeader) : boolean;
begin
    Result := true;
    with WaveHeader do begin
        if chIdRiff <> 'RIFF' then Result := false;
        if waveId <> 'WAVE' then Result := false;
        if chIdFmt <> 'fmt ' then Result := false;
        if cdIdData <> 'data' then Result := false;
    end;
end;

function GetWaveTime(var WaveHeader: TNoPcmWaveHeader) : double;
  //wSamples : integer;
begin
  //wSamples := (WaveHeader.chSizeData) div WaveHeader.wBitsPerSample;
  Result := WaveHeader.chSizeData / (WaveHeader.nSamplesPerSec * WaveHeader.nChannels * WaveHeader.wBitsPerSample div 8);
  //Result := ((wSamples * 1000) / WaveHeader.nSamplesPerSec) / WaveHeader.nChannels;
end;

end.