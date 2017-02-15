# Protobuffy

(the JSON slayer)

[![Gem Version](https://badge.fury.io/rb/protobuf.svg)](http://badge.fury.io/rb/protobuf)
[![Build Status](https://secure.travis-ci.org/ruby-protobuf/protobuf.svg?branch=master)](https://travis-ci.org/ruby-protobuf/protobuf)
[![Gitter chat](https://badges.gitter.im/ruby-protobuf/protobuf.svg)](https://gitter.im/ruby-protobuf/protobuf)
[![protobuf API Documentation](https://www.omniref.com/ruby/gems/protobuf.png)](https://www.omniref.com/ruby/gems/protobuf)

Protobuffy is an implementation of [Google's protocol buffers][google-pb] in
ruby, version 2.5.0 is currently supported.

## Install

See our [Installation Guide][] on the [wiki][].

## Usage

The [wiki][] contains in-depth guides on the various ways to use this gem
including [compiling definitions][], [object APIs][], [services][], [clients][], and even
an [API roadmap][].

## Examples

In two different terminals run the follow pairs of commands:

Socket:

    bundle exec bin/rpc_server start --socket ./examples/lib/example/reverse-service.rb
    bundle exec examples/bin/reverse-client-socket '!skrow tekcos'

ZeroMQ:

    bundle exec bin/rpc_server start --zmq ./examples/lib/example/reverse-service.rb
    bundle exec examples/bin/reverse-client-zmq '!skrow qmorez'

HTTP:

    bundle exec bin/rpc_server start --http ./examples/lib/example/reverse-service.rb
    bundle exec examples/bin/reverse-client-http '!skrow ptth'

Alternatively, start the server as a Rack app using a `rackup` and a standard `config.ru`:

    bundle exec rackup examples/config.ru -p 9399

## Changelog

See recent changes in the [release notes][] or the [changelog][].

  [google-pb]:             http://code.google.com/p/protobuf "Google Protocol Buffers"
  [wiki]:                  https://github.com/ruby-protobuf/protobuf/wiki "Wiki home page"
  [Installation Guide]:    https://github.com/ruby-protobuf/protobuf/wiki/Installation "Installation guide"
  [compiling definitions]: https://github.com/ruby-protobuf/protobuf/wiki/Compiling-Definitions "Compiling guide"
  [object APIs]:           https://github.com/ruby-protobuf/protobuf/wiki/Messages-&-Enums "Message & Enum object APIs guide"
  [services]:              https://github.com/ruby-protobuf/protobuf/wiki/Services "Services object API guide"
  [clients]:               https://github.com/ruby-protobuf/protobuf/wiki/Clients "Client object API guide"
  [API roadmap]:           https://github.com/ruby-protobuf/protobuf/wiki/API-Roadmap "API Roadmap guide"
  [release notes]:         https://github.com/ruby-protobuf/protobuf/releases "Release notes"
  [changelog]:             https://github.com/ruby-protobuf/protobuf/blob/master/CHANGES.md "CHANGES.md"
