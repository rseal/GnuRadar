// Generated by the protocol buffer compiler.  DO NOT EDIT!

#define INTERNAL_SUPPRESS_PROTOBUF_FIELD_DEPRECATION
#include <commands/Control.hpp>

#include <algorithm>

#include <google/protobuf/stubs/once.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/wire_format_lite_inl.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/reflection_ops.h>
#include <google/protobuf/wire_format.h>
// @@protoc_insertion_point(includes)

namespace gnuradar {

namespace {

const ::google::protobuf::Descriptor* ControlMessage_descriptor_ = NULL;
const ::google::protobuf::internal::GeneratedMessageReflection*
  ControlMessage_reflection_ = NULL;

}  // namespace


void protobuf_AssignDesc_Control_2eproto() {
  protobuf_AddDesc_Control_2eproto();
  const ::google::protobuf::FileDescriptor* file =
    ::google::protobuf::DescriptorPool::generated_pool()->FindFileByName(
      "Control.proto");
  GOOGLE_CHECK(file != NULL);
  ControlMessage_descriptor_ = file->message_type(0);
  static const int ControlMessage_offsets_[3] = {
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(ControlMessage, name_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(ControlMessage, source_),
    GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(ControlMessage, destination_),
  };
  ControlMessage_reflection_ =
    new ::google::protobuf::internal::GeneratedMessageReflection(
      ControlMessage_descriptor_,
      ControlMessage::default_instance_,
      ControlMessage_offsets_,
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(ControlMessage, _has_bits_[0]),
      GOOGLE_PROTOBUF_GENERATED_MESSAGE_FIELD_OFFSET(ControlMessage, _unknown_fields_),
      -1,
      ::google::protobuf::DescriptorPool::generated_pool(),
      ::google::protobuf::MessageFactory::generated_factory(),
      sizeof(ControlMessage));
}

namespace {

GOOGLE_PROTOBUF_DECLARE_ONCE(protobuf_AssignDescriptors_once_);
inline void protobuf_AssignDescriptorsOnce() {
  ::google::protobuf::GoogleOnceInit(&protobuf_AssignDescriptors_once_,
                 &protobuf_AssignDesc_Control_2eproto);
}

void protobuf_RegisterTypes(const ::std::string&) {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedMessage(
    ControlMessage_descriptor_, &ControlMessage::default_instance());
}

}  // namespace

void protobuf_ShutdownFile_Control_2eproto() {
  delete ControlMessage::default_instance_;
  delete ControlMessage_reflection_;
}

void protobuf_AddDesc_Control_2eproto() {
  static bool already_here = false;
  if (already_here) return;
  already_here = true;
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  ::google::protobuf::DescriptorPool::InternalAddGeneratedFile(
    "\n\rControl.proto\022\010gnuradar\"C\n\016ControlMess"
    "age\022\014\n\004name\030\001 \002(\t\022\016\n\006source\030\002 \002(\t\022\023\n\013des"
    "tination\030\003 \002(\t", 94);
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedFile(
    "Control.proto", &protobuf_RegisterTypes);
  ControlMessage::default_instance_ = new ControlMessage();
  ControlMessage::default_instance_->InitAsDefaultInstance();
  ::google::protobuf::internal::OnShutdown(&protobuf_ShutdownFile_Control_2eproto);
}

// Force AddDescriptors() to be called at static initialization time.
struct StaticDescriptorInitializer_Control_2eproto {
  StaticDescriptorInitializer_Control_2eproto() {
    protobuf_AddDesc_Control_2eproto();
  }
} static_descriptor_initializer_Control_2eproto_;


// ===================================================================

#ifndef _MSC_VER
const int ControlMessage::kNameFieldNumber;
const int ControlMessage::kSourceFieldNumber;
const int ControlMessage::kDestinationFieldNumber;
#endif  // !_MSC_VER

ControlMessage::ControlMessage()
  : ::google::protobuf::Message() {
  SharedCtor();
}

void ControlMessage::InitAsDefaultInstance() {
}

ControlMessage::ControlMessage(const ControlMessage& from)
  : ::google::protobuf::Message() {
  SharedCtor();
  MergeFrom(from);
}

void ControlMessage::SharedCtor() {
  _cached_size_ = 0;
  name_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  source_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  destination_ = const_cast< ::std::string*>(&::google::protobuf::internal::kEmptyString);
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
}

ControlMessage::~ControlMessage() {
  SharedDtor();
}

void ControlMessage::SharedDtor() {
  if (name_ != &::google::protobuf::internal::kEmptyString) {
    delete name_;
  }
  if (source_ != &::google::protobuf::internal::kEmptyString) {
    delete source_;
  }
  if (destination_ != &::google::protobuf::internal::kEmptyString) {
    delete destination_;
  }
  if (this != default_instance_) {
  }
}

void ControlMessage::SetCachedSize(int size) const {
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
}
const ::google::protobuf::Descriptor* ControlMessage::descriptor() {
  protobuf_AssignDescriptorsOnce();
  return ControlMessage_descriptor_;
}

const ControlMessage& ControlMessage::default_instance() {
  if (default_instance_ == NULL) protobuf_AddDesc_Control_2eproto();  return *default_instance_;
}

ControlMessage* ControlMessage::default_instance_ = NULL;

ControlMessage* ControlMessage::New() const {
  return new ControlMessage;
}

void ControlMessage::Clear() {
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (has_name()) {
      if (name_ != &::google::protobuf::internal::kEmptyString) {
        name_->clear();
      }
    }
    if (has_source()) {
      if (source_ != &::google::protobuf::internal::kEmptyString) {
        source_->clear();
      }
    }
    if (has_destination()) {
      if (destination_ != &::google::protobuf::internal::kEmptyString) {
        destination_->clear();
      }
    }
  }
  ::memset(_has_bits_, 0, sizeof(_has_bits_));
  mutable_unknown_fields()->Clear();
}

bool ControlMessage::MergePartialFromCodedStream(
    ::google::protobuf::io::CodedInputStream* input) {
#define DO_(EXPRESSION) if (!(EXPRESSION)) return false
  ::google::protobuf::uint32 tag;
  while ((tag = input->ReadTag()) != 0) {
    switch (::google::protobuf::internal::WireFormatLite::GetTagFieldNumber(tag)) {
      // required string name = 1;
      case 1: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
          DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                input, this->mutable_name()));
          ::google::protobuf::internal::WireFormat::VerifyUTF8String(
            this->name().data(), this->name().length(),
            ::google::protobuf::internal::WireFormat::PARSE);
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(18)) goto parse_source;
        break;
      }
      
      // required string source = 2;
      case 2: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_source:
          DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                input, this->mutable_source()));
          ::google::protobuf::internal::WireFormat::VerifyUTF8String(
            this->source().data(), this->source().length(),
            ::google::protobuf::internal::WireFormat::PARSE);
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectTag(26)) goto parse_destination;
        break;
      }
      
      // required string destination = 3;
      case 3: {
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_LENGTH_DELIMITED) {
         parse_destination:
          DO_(::google::protobuf::internal::WireFormatLite::ReadString(
                input, this->mutable_destination()));
          ::google::protobuf::internal::WireFormat::VerifyUTF8String(
            this->destination().data(), this->destination().length(),
            ::google::protobuf::internal::WireFormat::PARSE);
        } else {
          goto handle_uninterpreted;
        }
        if (input->ExpectAtEnd()) return true;
        break;
      }
      
      default: {
      handle_uninterpreted:
        if (::google::protobuf::internal::WireFormatLite::GetTagWireType(tag) ==
            ::google::protobuf::internal::WireFormatLite::WIRETYPE_END_GROUP) {
          return true;
        }
        DO_(::google::protobuf::internal::WireFormat::SkipField(
              input, tag, mutable_unknown_fields()));
        break;
      }
    }
  }
  return true;
#undef DO_
}

void ControlMessage::SerializeWithCachedSizes(
    ::google::protobuf::io::CodedOutputStream* output) const {
  // required string name = 1;
  if (has_name()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->name().data(), this->name().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    ::google::protobuf::internal::WireFormatLite::WriteString(
      1, this->name(), output);
  }
  
  // required string source = 2;
  if (has_source()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->source().data(), this->source().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    ::google::protobuf::internal::WireFormatLite::WriteString(
      2, this->source(), output);
  }
  
  // required string destination = 3;
  if (has_destination()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->destination().data(), this->destination().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    ::google::protobuf::internal::WireFormatLite::WriteString(
      3, this->destination(), output);
  }
  
  if (!unknown_fields().empty()) {
    ::google::protobuf::internal::WireFormat::SerializeUnknownFields(
        unknown_fields(), output);
  }
}

::google::protobuf::uint8* ControlMessage::SerializeWithCachedSizesToArray(
    ::google::protobuf::uint8* target) const {
  // required string name = 1;
  if (has_name()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->name().data(), this->name().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    target =
      ::google::protobuf::internal::WireFormatLite::WriteStringToArray(
        1, this->name(), target);
  }
  
  // required string source = 2;
  if (has_source()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->source().data(), this->source().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    target =
      ::google::protobuf::internal::WireFormatLite::WriteStringToArray(
        2, this->source(), target);
  }
  
  // required string destination = 3;
  if (has_destination()) {
    ::google::protobuf::internal::WireFormat::VerifyUTF8String(
      this->destination().data(), this->destination().length(),
      ::google::protobuf::internal::WireFormat::SERIALIZE);
    target =
      ::google::protobuf::internal::WireFormatLite::WriteStringToArray(
        3, this->destination(), target);
  }
  
  if (!unknown_fields().empty()) {
    target = ::google::protobuf::internal::WireFormat::SerializeUnknownFieldsToArray(
        unknown_fields(), target);
  }
  return target;
}

int ControlMessage::ByteSize() const {
  int total_size = 0;
  
  if (_has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    // required string name = 1;
    if (has_name()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::StringSize(
          this->name());
    }
    
    // required string source = 2;
    if (has_source()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::StringSize(
          this->source());
    }
    
    // required string destination = 3;
    if (has_destination()) {
      total_size += 1 +
        ::google::protobuf::internal::WireFormatLite::StringSize(
          this->destination());
    }
    
  }
  if (!unknown_fields().empty()) {
    total_size +=
      ::google::protobuf::internal::WireFormat::ComputeUnknownFieldsSize(
        unknown_fields());
  }
  GOOGLE_SAFE_CONCURRENT_WRITES_BEGIN();
  _cached_size_ = total_size;
  GOOGLE_SAFE_CONCURRENT_WRITES_END();
  return total_size;
}

void ControlMessage::MergeFrom(const ::google::protobuf::Message& from) {
  GOOGLE_CHECK_NE(&from, this);
  const ControlMessage* source =
    ::google::protobuf::internal::dynamic_cast_if_available<const ControlMessage*>(
      &from);
  if (source == NULL) {
    ::google::protobuf::internal::ReflectionOps::Merge(from, this);
  } else {
    MergeFrom(*source);
  }
}

void ControlMessage::MergeFrom(const ControlMessage& from) {
  GOOGLE_CHECK_NE(&from, this);
  if (from._has_bits_[0 / 32] & (0xffu << (0 % 32))) {
    if (from.has_name()) {
      set_name(from.name());
    }
    if (from.has_source()) {
      set_source(from.source());
    }
    if (from.has_destination()) {
      set_destination(from.destination());
    }
  }
  mutable_unknown_fields()->MergeFrom(from.unknown_fields());
}

void ControlMessage::CopyFrom(const ::google::protobuf::Message& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

void ControlMessage::CopyFrom(const ControlMessage& from) {
  if (&from == this) return;
  Clear();
  MergeFrom(from);
}

bool ControlMessage::IsInitialized() const {
  if ((_has_bits_[0] & 0x00000007) != 0x00000007) return false;
  
  return true;
}

void ControlMessage::Swap(ControlMessage* other) {
  if (other != this) {
    std::swap(name_, other->name_);
    std::swap(source_, other->source_);
    std::swap(destination_, other->destination_);
    std::swap(_has_bits_[0], other->_has_bits_[0]);
    _unknown_fields_.Swap(&other->_unknown_fields_);
    std::swap(_cached_size_, other->_cached_size_);
  }
}

::google::protobuf::Metadata ControlMessage::GetMetadata() const {
  protobuf_AssignDescriptorsOnce();
  ::google::protobuf::Metadata metadata;
  metadata.descriptor = ControlMessage_descriptor_;
  metadata.reflection = ControlMessage_reflection_;
  return metadata;
}


// @@protoc_insertion_point(namespace_scope)

}  // namespace gnuradar

// @@protoc_insertion_point(global_scope)