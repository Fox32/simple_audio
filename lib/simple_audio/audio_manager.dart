part of simple_audio;

/** The [AudioManager] class is the main entry point to the [simple_audio]
 * library. You can create [AudioClip]s and [AudioSource]s with the manager.
 * You can play clips from sources with the manager.
 *
 * The [AudioManager] also has a listener which picks up sounds from
 * [AudioSource]s. The sound picked up by the listener from the [AudioSource]s
 * is played through the real, physical speakers attached to the computer.
 *
 */
class AudioManager {
  AudioContext _context;
  AudioDestinationNode _destination;
  AudioListener _listener;

  GainNode _masterGain;
  GainNode _musicGain;
  GainNode _sourceGain;

  Map<String, AudioClip> _clips = new Map<String, AudioClip>();
  Map<String, AudioSource> _sources = new Map<String, AudioSource>();
  AudioMusic _music;

  /** Construct a new AudioManager */
  AudioManager() {
    _context = new AudioContext();
    _destination = _context.destination;
    _listener = _context.listener;

    _masterGain = _context.createGain();
    _musicGain = _context.createGain();
    _sourceGain = _context.createGain();

    _masterGain.connect(_destination, 0, 0);
    _musicGain.connect(_masterGain, 0, 0);
    _sourceGain.connect(_masterGain, 0, 0);

    _music = new AudioMusic._internal(this, _musicGain);
  }

  /** Sample rate of the audio driver */
  num get sampleRate => _context.sampleRate;

  /** Get the music volume. */
  num get musicVolume => _musicGain.gain.value;
  /** Set the music volume. */
  void set musicVolume(num mv) {
    _musicGain.gain.value = mv;
  }

  /** Get the master volume. */
  num get masterVolume => _masterGain.gain.value;
  /** Set the master volume. */
  void set masterVolume(num mv) {
    mute = false;
    _masterGain.gain.value = mv;
  }

  /** Get the sources volume */
  num get sourceVolume => _sourceGain.gain.value;
  /** Set the sources volume */
  void set sourceVolume(num mv) {
    _sourceGain.gain.value = mv;
  }

  num _mutedVolume;
  /** Is the master volume muted? */
  bool get mute => _mutedVolume != null;

  /** Control the master mute */
  void set mute(bool b) {
    if (b) {
     if (_mutedVolume != null) {
       // Double mute.
       return;
     }
     _mutedVolume = _masterGain.gain.value;
     _masterGain.gain.value = 0;
    } else {
      if (_mutedVolume == null) {
        // Double unmute.
        return;
      }
      _masterGain.gain.value = _mutedVolume;
      _mutedVolume = null;
    }
  }

  /** Pause both music and source based sounds. */
  void pauseAll() {
    pauseSources();
    pauseMusic();
  }

  /** Resume both music and source based sounds. */
  void resumeAll() {
    resumeSources();
    resumeMusic();
  }

  bool _musicPaused = false;
  /** Pause music sounds */
  void pauseMusic() {
    _music.pause = true;
    _musicPaused = true;
  }
  /** Resume music sounds */
  void resumeMusic() {
    _music.pause = false;
    _musicPaused = false;
  }

  bool _sourcesPaused = false;
  /** Pause source base sounds. */
  void pauseSources() {
    _sources.forEach((k,v) {
      v.pause = true;
    });
    _sourcesPaused = true;
  }

  /** Resume source base sounds. */
  void resumeSources() {
    _sources.forEach((k,v) {
      v.pause = false;
    });
    _sourcesPaused = false;
  }

  /** Find the audio clip with [name] */
  AudioClip findClip(String name) {
    return _clips[name];
  }

  /** Find the audio source with [name] */
  AudioSource findSource(String name) {
    return _sources[name];
  }

  /** Get the [AudioMusic] singleton. */
  AudioMusic get music => _music;

  /** Create an [AudioClip] with [name]. */
  AudioClip makeClip(String name) {
    AudioClip clip = _clips[name];
    if (clip != null) {
      return clip;
    }
    clip = new AudioClip._internal(this, name);
    _clips[name] = clip;
    return clip;
  }

  /** Create an [AudioSource] and assign it [name] */
  AudioSource makeSource(String name) {
    AudioSource source = _sources[name];
    if (source != null) {
      return source;
    }
    source = new AudioSource._internal(this, _sourceGain);
    _sources[name] = source;
    return source;
  }

  /** Play [clipName] from [sourceName]. */
  AudioSound playClipFromSource(String sourceName, String clipName, [bool looped=false]) {
    return playClipFromSourceIn(0.0, sourceName, clipName, looped);
  }

  /** Play [clipName] from [sourceName] in [delay] seconds. */
  AudioSound playClipFromSourceIn(num delay, String sourceName, String clipName, [bool looped=false]) {
    AudioSource source = _sources[sourceName];
    if (source == null) {
      // TODO(johnmccutchan): Determine error route.
      print('Could not find source $sourceName');
      return null;
    }
    AudioClip clip = _clips[clipName];
    if (clip == null) {
      // TODO(johnmccutchan): Determine error route.
      print('Could not find clip $clipName');
      return null;
    }
    if (looped) {
      return source.playLoopedIn(delay, clip);
    } else {
      return source.playOnceIn(delay, clip);
    }
  }

  /** Stop all sounds originating from [sourceName] */
  void stopSource(String sourceName) {
    AudioSource source = _sources[sourceName];
    if (source == null) {
      // TODO(johnmccutchan): Determine error route.
      print('Could not find source $sourceName');
      return;
    }
    source.stop();
  }

  /** Pause all sounds originating from [sourceName] */
  void pauseSource(String sourceName) {
    AudioSource source = _sources[sourceName];
    if (source == null) {
      // TODO(johnmccutchan): Determine error route.
      print('Could not find source $sourceName');
      return;
    }
    source.pause = true;
  }

  /** Resume all sounds originating from [sourceName] */
  void resumeSource(String sourceName) {
    AudioSource source = _sources[sourceName];
    if (source == null) {
      // TODO(johnmccutchan): Determine error route.
      print('Could not find source $sourceName');
      return;
    }
    source.pause = false;
  }

  num get dopplerFactor => _listener.dopplerFactor;

  void set dopplerFactor(num df) {
    _listener.dopplerFactor = df;
  }

  num get speedOfSound => _listener.speedOfSound;

  void set speedOfSound(num sos) {
    _listener.speedOfSound = sos;
  }

  void setOrientation(num xForward, num yForward, num zForward,
                      num xUp, num yUp, num zUp) {
    _listener.setOrientation(xForward, yForward, zForward,
                             xUp, yUp, zUp);
  }

  void setPosition(num x, num y, num z) {
    _listener.setPosition(x, y, z);
  }

  void setVelocity(num x, num y, num z) {
    _listener.setVelocity(x, y, z);
  }
}

/* TODO:
 * Basic Demo:
 *    Add clip selection drop down (not just scream).
 *    Add music selection drop down (1 more song).
 *    Add clip selection to each source.
 */