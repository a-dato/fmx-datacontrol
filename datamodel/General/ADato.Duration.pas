{$I ..\Source\Adato.inc}

unit ADato.Duration;

interface

uses
  {$IFDEF DOTNET}
  System.Text,
  System.Threading,
  {$ENDIF}
  System_;

type
  {
    Overview:
      Helper class that encapsulates DurationSettings and provides property setters and getters for the variables stored therein.

    Description:
      DurationSettings stores input characters used for parsing user input.
      This class is used in calls to FormatDuration and ParseDuration to provide
      a thread-safe implementation.
      When parsing data entered by the user certain chartacters are recognized
      as indicators for the type a value represents. For example if a user
      enters '5h' then this is read as 5 hours while entering only '5' would
      have been read as 5 days. Because different languages use different
      characters, you can use the properties contained in this class to set
      the characters that mark certain values.

      By default DayChar is set to 'd', HourChar is set to 'h', MinuteChar is
      set to 'm', SecondsChar is set to 's' and MSecondsChar is set to 'z'.
      Therefore, when the user enters '5d 4h 3m 40s 100z' then this is
      converted to:

      5 * HoursPerDay/24 + 4 hours + 3 minutes + 40 seconds + 100 miliseconds.

      If the input characters are not included in the input string then
      ParseDuration will still try to convert the string to a proper duration
      value. It thereby assumes that data is entered in the order:
      days, hours, minutes, seconds and miliseconds.

  }
  {$M+}
  DurationSettings = class
  private
    class var _default: CObject; // Owns instance
    class var _longNamesDefault: CObject; // Owns instance

  private
    _defaultChar,
    _weekChar,
    _weeksChar,
    _dayChar,
    _daysChar,
    _hourChar,
    _hoursChar,
    _nullValue,
    _minuteChar,
    _minutesChar,
    _minusChar,
    _secondChar,
    _secondsChar,
    _mSecondsChar: CString;
    _timeSeparator,
    _decimalSeparator: CString;
    _daysPerWeek: Integer;
    _hoursPerDay: CTimeSpan;

  protected
    class function get_Default: DurationSettings; static;
    class function get_LongNamesDefault: DurationSettings; static;

  public
    {
      Overview:
        Creates a new instance of DurationSettings.
      Description:
        Create allocates a new instance of the DurationSettings class.
    }
    constructor Create;

    function IsSpecifier(const c: CString) : Boolean;
    function Clone: DurationSettings;

    class property Default: DurationSettings read get_Default;
    class property LongNamesDefault: DurationSettings read get_LongNamesDefault;

  published
    {
      Overview:
        Holds the chartacter used to indicate a day value.
    }
    property DayChar: CString read _dayChar write _dayChar;
    property DaysChar: CString read _daysChar write _daysChar;
    property DaysPerWeek: Integer read _daysPerWeek write _daysPerWeek;

    {
      Overview:
        Holds the chartacter used to indicate an hour value.
      Description:
        When parsing data entered by the user this property holds the character
        that indicates that an hour value was entered. For example if a user
        entered '5h' then the result would be 5 hours.

        By default this property is set to 'h'.
    }
    property HourChar: CString read _hourChar write _hourChar;
    property HoursChar: CString read _hoursChar write _hoursChar;

    {
      Overview:
        Holds the chartacter used to indicate a minute value.
      Description:
        When parsing data entered by the user this property holds the character
        that indicates a minute value was entered. For example if a user
        entered '5m' then the result would be 5 minutes.

        By default this property is set to 'm'.
    }
    property MinuteChar: CString read _minuteChar write _minuteChar;
    property MinutesChar: CString read _minutesChar write _minutesChar;

    property MinusChar: CString read _minusChar write _minusChar;

    {
      Overview:
        Holds the chartacter used to indicate a seconds value.
      Description:
        When parsing data entered by the user this property holds the character
        that indicates a second value was entered. For example if a user
        entered '5s' then the result would be 5 seconds.

        By default this property is set to 's'.
    }
    property SecondChar: CString read _secondChar write _secondChar;
    property SecondsChar: CString read _secondsChar write _secondsChar;

    {
      Overview:
        Holds the chartacter used to indicate a miliseconds value.

      Description:
        When parsing data entered by the user this property holds the character
        that indicates a milisecond value was entered. For example if a user
        entered '5z' then the result would be 5 miliseconds.

        By default this property is set to 'z'.
    }
    property MSecondsChar: CString read _mSecondsChar write _mSecondsChar;

    property WeekChar: CString read _weekChar write _weekChar;
    property WeeksChar: CString read _weeksChar write _weeksChar;

    {
      Overview:
       Holds the number of hours contained in a working day.
      Description:
        This value is used to translate between real days (24 hours) and
        working days. Many times, when a users enters a duration of 1 day, he
        or she actually means a working day. A working day normally equals to
        8 hours and therefore the calculated value should be 1*8/24 instead of 1.
        This property allows you to control such behaviour.

        Set HoursPerDay to the number of workinghours in a regular working day.
        Now, when a duration is parsed and/or displayed, 1 day represents
        HoursPerDay instead of real day (24 hours).
    }
    property HoursPerDay: CTimeSpan read _hoursPerDay write _hoursPerDay;

    {
      Overview:
        Holds the chartacter used by default, that is when the inputstring does
        not contain any other characters.
      Description:
        When parsing data entered by the user this property holds the default
        character used if an inputcharacter is not present. For example if a
        user entered '5' the parser function would not know whether the user
        meant 5 days, hours, minutes or whatever. In such situations, the
        default character will be used. Therefore if the default character
        equals DayChar then the value would be read as 5 days, if the default
        character equals HourChar then the value would be read as 5 hours.

        By default this property is set to 'd' which equals DayChar.
    }
    property DefaultChar: CString read _defaultChar write _defaultChar;
    property NullValue: CString read _nullValue write _nullValue;

    property TimeSeparator: CString read _timeSeparator write _timeSeparator;
    property DecimalSeparator: CString read _decimalSeparator write _decimalSeparator;
  end;
  {$M-}

  DurationFlags = record
  const
    None = 0;
    AddSignWhenNegative = 2;
    AllwaysAddSign = 4;
    AddBrackets = 8;
    ShowDays = 16;
    ShowNullValue = 32;
    RoundUp = 64;
    HideSymbol = 128;
    ShowSeconds = 256;

  {$IFDEF DELPHI}
	strict private
    value: Integer;
  {$ELSE}
  private strict
    value: Integer;
	{$ENDIF}

  public
    class operator Equal(const L, R: DurationFlags) : Boolean;
    class operator NotEqual(const L, R: DurationFlags) : Boolean;
    class operator Implicit(AValue: Integer) : DurationFlags;
    class operator Implicit(const AValue: DurationFlags) : Integer;
    {$IFDEF DELPHI}
    class operator LogicalOr(const L, R: DurationFlags) : DurationFlags;
    class operator LogicalAnd(const L, R: DurationFlags) : DurationFlags;
    {$ELSE}
    class operator BitwiseOr(const L, R: DurationFlags) : DurationFlags;
    class operator BitwiseAnd(const L, R: DurationFlags) : DurationFlags;
    {$ENDIF}
  end;

  Duration = class
    public class function Format( const Value: CTimeSpan;
                                  const Settings: DurationSettings;
                                  const Flags: DurationFlags) : CString;
    public class function Parse(const Value: CString; const Settings: DurationSettings) : CTimeSpan;
  end;

implementation

uses
  {$IFDEF DELPHI}
  SysUtils,
  System_.Threading
	{$ENDIF};

{ DurationFlags }
class operator DurationFlags.Equal(const L, R: DurationFlags) : Boolean;
begin
  Result := L.value = R.value;
end;

class operator DurationFlags.NotEqual(const L, R: DurationFlags) : Boolean;
begin
  Result := L.value <> R.value;
end;

class operator DurationFlags.Implicit(AValue: Integer) : DurationFlags;
begin
  Result.value := AValue;
end;

class operator DurationFlags.Implicit(const AValue: DurationFlags) : Integer;
begin
  Result := AValue.value;
end;

{$IFDEF DELPHI}
class operator DurationFlags.LogicalOr(const L, R: DurationFlags) : DurationFlags;
begin
  Result.value := L.value or R.value;
end;

class operator DurationFlags.LogicalAnd(const L, R: DurationFlags) : DurationFlags;
begin
  Result.value := L.value and R.value;
end;
{$ELSE}
class operator DurationFlags.BitwiseOr(const L, R: DurationFlags) : DurationFlags;
begin
  Result.value := L.value or R.value;
end;

class operator DurationFlags.BitwiseAnd(const L, R: DurationFlags) : DurationFlags;
begin
  Result.value := L.value and R.value;
end;
{$ENDIF}

{$IFDEF WP_DAYS}
{ Duration }
class function Duration.Format(
  const Value: CTimeSpan;
  const Settings: DurationSettings;
  const Flags: DurationFlags) : CString;
var
  days: Integer;
  hasData: Boolean;
  useDuration: CTimeSpan;
  hours: Integer;
  mins: Integer;
  sb: StringBuilder;
  secs: Integer;

begin
  hasData := False;
  sb := CStringBuilder.Create(30); // 240H 10M 45S

  var defaultToDays := ((Flags and DurationFlags.ShowDays) <> DurationFlags.None) or Settings.DayChar.Equals(Settings.DefaultChar);

  if Value.Equals(CTimeSpan.Zero) then
  begin
    if (Flags and DurationFlags.ShowNullValue) = DurationFlags.ShowNullValue then
    begin
      if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
        sb.Append('(');

      sb.Append(Settings.NullValue);

      if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
        sb.Append(')');
    end;

    Exit(sb.ToString);
  end;

  if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
    sb.Append('(');

  if defaultToDays and not Settings.HoursPerDay.Equals(CTimeSpan.Zero) then
  begin
    days := (Value.Ticks div Settings.HoursPerDay.Ticks);
    useDuration := CTimeSpan.Create(days * CTimeSpan.TicksPerDay + Value.Ticks mod Settings.HoursPerDay.Ticks);
  end else
    useDuration := Value;

  if useDuration.Ticks < 0 then
  begin
    if (Flags and (DurationFlags.AddSignWhenNegative or DurationFlags.AllwaysAddSign)) <> DurationFlags.None then
      sb.Append('-/-');
  end
  else if (Flags and DurationFlags.AllwaysAddSign) <> DurationFlags.None then
    sb.Append('+');

  if (Flags and DurationFlags.RoundUp) = DurationFlags.RoundUp then
  begin
    if useDuration.Subtract(CTimeSpan.Create(useDuration.Days, 0, 0, 0)).Ticks > 0 then
      useDuration := CTimeSpan.Create(useDuration.Days + 1, 0, 0, 0);
  end;

  days := useDuration.Days;
  if (days <> 0) and defaultToDays then
  begin
    hasData := True;
    sb.Append(days);

    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (days > 1) or (days < -1) then
        sb.Append(Settings.DaysChar) else
        sb.Append(Settings.DayChar);
    end;
  end;

  if defaultToDays then
    hours := useDuration.Hours else
    hours := days * 24 + useDuration.Hours;

  mins := useDuration.Minutes;
  secs := useDuration.Seconds;

  // Hide seconds field?
  if Flags and DurationFlags.ShowSeconds = DurationFlags.None then
  begin
    if secs >= 30 then
    begin
      if mins = 59 then
      begin
        mins := 0;
        inc(hours);
      end else
        inc(mins);
    end;

    secs := 0;
  end;

  if (hours <> 0) then
  begin
    if hasData then
      sb.Append(' ');

    hasData := True;
    sb.Append(hours);
    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (hours > 1) or (hours < -1) then
        sb.Append(Settings.HoursChar) else
        sb.Append(Settings.HourChar);
    end;
  end;

  if (mins <> 0) or (secs <> 0) then
  begin
    if hasData then
      sb.Append(' ');

    hasData := True;
    sb.Append(mins);
    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (mins > 1) or (mins < -1) then
        sb.Append(Settings.MinutesChar) else
        sb.Append(Settings.MinuteChar);
    end;
  end;

  if secs <> 0 then
  begin
    if hasData then
      sb.Append(' ');
    sb.Append(secs);
    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (secs > 1) or (secs < -1) then
        sb.Append(Settings.SecondsChar) else
        sb.Append(Settings.SecondChar);
    end;
  end;

  if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
    sb.Append(')');

  Result := sb.ToString;
end;
{$ELSE}
{ Duration }
class function Duration.Format(
  const Value: CTimeSpan;
  const Settings: DurationSettings;
  const Flags: DurationFlags) : CString;
var
  days: Integer;
  hasData: Boolean;
  useDuration: CTimeSpan;
  hours: Integer;
  mins: Integer;
  sb: StringBuilder;
  secs: Integer;

begin
  hasData := False;
  sb := CStringBuilder.Create(30); // 240H 10M 45S

  if Value.Equals(CTimeSpan.Zero) then
  begin
    if (Flags and DurationFlags.ShowNullValue) = DurationFlags.ShowNullValue then
    begin
      if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
        sb.Append('(');

      sb.Append(Settings.NullValue);

      if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
        sb.Append(')');
    end;

    Exit(sb.ToString);
  end;

  if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
    sb.Append('(');

  if ((Flags and DurationFlags.ShowDays) <> DurationFlags.None) and not Settings.HoursPerDay.Equals(CTimeSpan.Zero) then
  begin
    days := (Value.Ticks div Settings.HoursPerDay.Ticks);
    useDuration := CTimeSpan.Create(days * CTimeSpan.TicksPerDay + Value.Ticks mod Settings.HoursPerDay.Ticks);
  end else
    useDuration := Value;

  if useDuration.Ticks < 0 then
  begin
    if (Flags and (DurationFlags.AddSignWhenNegative or DurationFlags.AllwaysAddSign)) <> DurationFlags.None then
      sb.Append('-/-');
  end
  else if (Flags and DurationFlags.AllwaysAddSign) <> DurationFlags.None then
    sb.Append('+');

  if (Flags and DurationFlags.RoundUp) = DurationFlags.RoundUp then
  begin
    if useDuration.Subtract(CTimeSpan.Create(useDuration.Days, 0, 0, 0)).Ticks > 0 then
      useDuration := CTimeSpan.Create(useDuration.Days + 1, 0, 0, 0);
  end;

  days := useDuration.Days;
  if (days <> 0) and ((Flags and DurationFlags.ShowDays) <> DurationFlags.None) then
  begin
    hasData := True;
    sb.Append(days);

    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (days > 1) or (days < -1) then
        sb.Append(Settings.DaysChar) else
        sb.Append(Settings.DayChar);
    end;
  end;

  if (Flags and DurationFlags.ShowDays) = DurationFlags.ShowDays then
    hours := useDuration.Hours else
    hours := days * 24 + useDuration.Hours;

  mins := useDuration.Minutes;
  secs := useDuration.Seconds;

  // Hide seconds field?
  if Flags and DurationFlags.ShowSeconds = DurationFlags.None then
  begin
    if secs >= 30 then
    begin
      if mins = 59 then
      begin
        mins := 0;
        inc(hours);
      end else
        inc(mins);
    end;

    secs := 0;
  end;

  if (hours <> 0) then
  begin
    if hasData then
      sb.Append(' ');

    hasData := True;
    sb.Append(hours);
    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (hours > 1) or (hours < -1) then
        sb.Append(Settings.HoursChar) else
        sb.Append(Settings.HourChar);
    end;
  end;

  if (mins <> 0) or (secs <> 0) then
  begin
    if hasData then
      sb.Append(' ');

    hasData := True;
    sb.Append(mins);
    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (mins > 1) or (mins < -1) then
        sb.Append(Settings.MinutesChar) else
        sb.Append(Settings.MinuteChar);
    end;
  end;

  if secs <> 0 then
  begin
    if hasData then
      sb.Append(' ');
    sb.Append(secs);
    if Flags and DurationFlags.HideSymbol = DurationFlags.None then
    begin
      if (secs > 1) or (secs < -1) then
        sb.Append(Settings.SecondsChar) else
        sb.Append(Settings.SecondChar);
    end;
  end;

  if (Flags and DurationFlags.AddBrackets) <> DurationFlags.None then
    sb.Append(')');

  Result := sb.ToString;
end;
{$ENDIF}

class function Duration.Parse(const Value: CString; const Settings: DurationSettings): CTimeSpan;
var
  i, length: Integer;
  uom: CString;
  val: CString;
  isTimeValue: Boolean;
  isNegative: Boolean;
  saved2: CString;
  saved2IsTime: Boolean;
  savedIsTime: Boolean;
  savedVal: CString;
  __Result: CTimeSpan;

  function OnDecimalSeparator(pos: Integer) : Boolean;
  var
    n: Integer;
  begin
    Result := False;
    n := 0;
    while Value[i] = Settings.DecimalSeparator[n] do
    begin
      inc(i);
      inc(n);

      if n = Settings.DecimalSeparator.Length then
      begin
        Result := True;
        Exit;
      end;

      if i = length then
        Exit;
    end;
  end;

  function OnTimeSeparator(pos: Integer) : Boolean;
  var
    n: Integer;
  begin
    Result := False;
    n := 0;
    while Value[i] = Settings.TimeSeparator[n] do
    begin
      inc(i);
      inc(n);

      if n = Settings.TimeSeparator.Length then
      begin
        Result := True;
        Exit;
      end;

      if i = length then
        Exit;
    end;
  end;

  function IsValidInputChar(const chr: CChar): Boolean;
  begin
    Result := (chr = ' ') or
              CChar.IsDigit(chr) or
              (Settings.DefaultChar.IndexOf(chr) <> -1) or
              (Settings.DayChar.IndexOf(chr) <> -1) or
              (Settings.DaysChar.IndexOf(chr) <> -1) or
              (Settings.HourChar.IndexOf(chr) <> -1) or
              (Settings.HoursChar.IndexOf(chr) <> -1) or
              (Settings.MinuteChar.IndexOf(chr) <> -1) or
              (Settings.MinutesChar.IndexOf(chr) <> -1) or
              (Settings.MinusChar.IndexOf(chr) <> -1) or
              (Settings.SecondChar.IndexOf(chr) <> -1) or
              (Settings.SecondsChar.IndexOf(chr) <> -1) or
              (Settings.MSecondsChar.IndexOf(chr) <> -1) or
              (Settings.TimeSeparator.IndexOf(chr) <> -1) or
              (Settings.DecimalSeparator.IndexOf(chr) <> -1) or
              (Settings.WeekChar.IndexOf(chr) <> -1);
  end;

  procedure ReadPart;
  var
    C: CChar;
    n: Integer;

  begin
    C := Value[i];

    if not IsValidInputChar(C) then
      raise FormatException.Create(CString.Format('Invalid input character ''{0}''', C));

    if CChar.IsLetter(C) then
    begin
      n := i;

      while CChar.IsLetter(C) do
      begin
        inc(i);
        if i = length then
          break;
        C := Value[i];
      end;

      if n < i then
        uom := Value.Substring(n, i - n);
    end
    else if CChar.IsDigit(C) then
    begin
      n := i;
      isTimeValue := False;

      // Read number
      while i < length do
      begin
        if not CChar.IsDigit(C) then
        begin
          if OnTimeSeparator(i) then
            isTimeValue := True

          else if not OnDecimalSeparator(i) then
            break;
            //raise FormatException.Create(CString.Format('Failed to parse value ''{0}''', val));
        end;

        inc(i);
        if i = length then
          break;

        C := Value[i];
      end;

      if n < i then
        val := Value.Substring(n, i - n);
    end
    else if (i = 0) and (Settings.MinusChar.IndexOf(C) <> -1) then
    begin
      isNegative := True;
      inc(i);
    end
    else
      // Neither a digit nor a letter, whitespace?
      inc(i);
  end;

  function Contains(const DayChars: StringArray; const str: CString): Boolean;
  var
    i: Integer;
  begin
    Result := False;
    i := 0;
    while i < {$IFDEF DELPHI}System.Length(DayChars){$ELSE}DayChars.Length{$ENDIF} do
    begin
      if DayChars[i].Equals(str) then
      begin
        Result := True;
        Exit;
      end;
      inc(i);
    end;
  end;

  procedure SaveValue;
  var
    daychars: StringArray;
    dVal: Double;
    ticks: CInt64;
    lwr: CString;
    ts: CTimeSpan;

  begin
    if val = nil then
      raise FormatException.Create('Value must precede time indicator');

    if isTimeValue then
    begin
      if not CTimeSpan.TryParse(val, ts) then
        raise FormatException.Create(CString.Format('Failed to parse value ''{0}''', val));

      __Result := __Result.Add(ts);
    end
    else
    begin
      if not CDouble.TryParse(val, dVal) then
        raise FormatException.Create(CString.Format('Failed to parse value ''{0}''', val));

      ticks := 0;

      if not CString.IsNullOrEmpty(Settings.DaysChar) then
        daychars := Settings.DaysChar.Split(['|']) else
        daychars := nil;

      lwr := uom.ToLower;
      if lwr.Equals(Settings.DayChar.ToLower) or Contains(daychars, lwr) or Settings.DaysChar.ToLower.Contains(lwr) then
        ticks := CMath.Truncate(dVal * Int64(Settings.HoursPerDay.Ticks))
      else if lwr.Equals(Settings.WeekChar.ToLower) then
        ticks := CMath.Truncate(CMath.Truncate(dVal * Settings.DaysPerWeek) * Settings.HoursPerDay.Ticks)
      else if lwr.Equals(Settings.HourChar.ToLower) then
        ticks := CMath.Truncate(dVal * CTimeSpan.TicksPerHour)
      else if lwr.Equals(Settings.MinuteChar.ToLower) then
        ticks := CMath.Truncate(dVal * CTimeSpan.TicksPerMinute)
      else if lwr.Equals(Settings.SecondsChar.ToLower) then
        ticks := CMath.Truncate(dVal * CTimeSpan.TicksPerSecond)
      else if lwr.Equals(Settings.MSecondsChar.ToLower) then
        ticks := CMath.Truncate(dVal * CTimeSpan.TicksPerMillisecond)
      else
        raise FormatException.Create(CString.Format('Unrecognized character(s) ''{0}''', uom));

      __Result := __Result.Add(CTimeSpan.Create(ticks));
    end;

    if isNegative and (not __Result.Equals(CTimeSpan.Zero)) then
      __Result := CTimeSpan.Create(-__Result.Ticks);

    uom := nil;
    val := nil;
  end;

  procedure SaveDefaultValue;
  begin
    uom := Settings.DefaultChar;
    SaveValue;
  end;

begin
  try
    __Result := CTimeSpan.Zero;
    i := 0;
    length := Value.Length;

    uom := nil;
    val := nil;
    isNegative := False;

    while true do
    begin
      if i = length then
        break;

      ReadPart;

      if (val = nil) and (uom = nil) then
        continue;

      while uom = nil do
      begin
        if i = length then
        begin
          SaveDefaultValue;
          Exit(__Result);
        end;

        savedIsTime := isTimeValue;
        savedVal := val;
        val := nil;
        ReadPart;

        // Did ReadPart return a value again?
        if (val <> nil) then
        begin
          saved2 := val;
          saved2IsTime := isTimeValue;

          val := savedVal;
          isTimeValue := savedIsTime;

          SaveDefaultValue;

          val := saved2;
          isTimeValue := saved2IsTime;
        end
        else
        begin
          val := savedVal;
          isTimeValue := savedIsTime;
        end;
      end;

      if (uom <> nil) then
        SaveValue;
    end;

    Exit(__Result);
  except
    raise FormatException.Create(CString.Format('Cannot convert value ''{0}'' to a duration', Value));
  end;
end;

{ DurationSettings }

constructor DurationSettings.Create;
begin
  _defaultChar := 'h';
  _weekChar := 'w';
  _weeksChar := _weekChar;
  _dayChar := 'd';
  _daysChar := _dayChar;
  _hourChar := 'h';
  _hoursChar := _hourChar;
  _nullValue := '-';
  _minuteChar := 'm';
  _minutesChar := _minuteChar;
  _minusChar := '-';
  _secondChar := 's';
  _secondsChar := _secondChar;
  _mSecondsChar := 'z';
  _hoursPerDay := CTimeSpan.Create(0, 8, 0, 0);
  _daysPerWeek := 5; // CTimeSpan.Create(5, 0, 0, 0);
  _timeSeparator := Thread.CurrentThread.CurrentCulture.DateTimeFormat.TimeSeparator;
  _decimalSeparator := FormatSettings.DecimalSeparator;
end;

class function DurationSettings.get_Default : DurationSettings;
begin
  if _default = nil then
    _default := CObject.Create(DurationSettings.Create, True {Owns object});
  Result := DurationSettings(TObject(_default));
end;

class function DurationSettings.get_LongNamesDefault : DurationSettings;
begin
  if _longNamesDefault = nil then
  begin
    _longNamesDefault := CObject.Create(DurationSettings.Create, True {Owns object});
    Result := DurationSettings(TObject(_longNamesDefault));
    Result.DefaultChar := 'h';
    Result.DayChar := ' day';
    Result.DaysChar := ' days';
    Result.HourChar := ' hour';
    Result.HoursChar := ' hours';
    Result.MinuteChar := ' minute';
    Result.MinuteChar := ' minutes';
    Result.SecondChar := ' second';
    Result.SecondsChar := ' seconds';
    Result.WeekChar := ' week';
  end;

  Result := DurationSettings(TObject(_longNamesDefault));
end;

function DurationSettings.IsSpecifier(const c: CString): Boolean;
begin
  Result := c.Equals(_dayChar) or c.Equals(_hourChar) or
            c.Equals(_minuteChar) or c.Equals(_secondsChar) or
            c.Equals(_mSecondsChar) or c.Equals(_weekChar);
end;

function DurationSettings.Clone: DurationSettings;
begin
  Result := DurationSettings.Create;
  Result._defaultChar := _defaultChar;
  Result._weekChar := _weekChar;
  Result._weeksChar := _weeksChar;
  Result._dayChar := _dayChar;
  Result._daysChar := _daysChar;
  Result._hourChar := _hourChar;
  Result._hoursChar := _hoursChar;
  Result._nullValue := _nullValue;
  Result._minuteChar := _minuteChar;
  Result._minutesChar := _minutesChar;
  Result._minusChar := _minusChar;
  Result._secondChar := _secondChar;
  Result._secondsChar := _secondsChar;
  Result._mSecondsChar := _mSecondsChar;
  Result._timeSeparator := _timeSeparator;
  Result._decimalSeparator := _decimalSeparator;
  Result._daysPerWeek := _daysPerWeek;
  Result._hoursPerDay := _hoursPerDay;
end;

end.

