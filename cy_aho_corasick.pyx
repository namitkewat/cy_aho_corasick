# cython: c_string_type=unicode, c_string_encoding=utf8

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.vector cimport vector

from cpython.ref cimport Py_INCREF
from cpython.long cimport PyLong_FromLong
from cpython.tuple cimport PyTuple_New, PyTuple_SET_ITEM
from cpython.list cimport PyList_Append, PyList_GET_ITEM, PyList_GET_SIZE


cdef extern from "<string>" namespace "std" nogil:
    cdef cppclass basic_string[T]:
        const T* c_str() const

ctypedef basic_string[char] string_type

cdef extern from "./src/aho_corasick.hpp" namespace "aho_corasick" nogil:
    cdef cppclass interval:
        interval(size_t, size_t)
        size_t get_start()
        size_t get_end()
        size_t size()

        bool overlaps_with(const interval&)
        bool overlaps_with(size_t point)

        bool operator <(const interval&)
        bool operator !=(const interval&)
        bool operator ==(const interval&)
    
    cdef cppclass emit[T](interval):
        emit() except +
        emit(size_t, size_t, string_type, unsigned)
        string_type get_keyword()
        unsigned get_index()
        bool is_empty()

    cdef cppclass basic_trie[T]:
        ctypedef emit[T] emit_type
        ctypedef vector[emit_type] emit_collection

        cppclass config:
            bool d_allow_overlaps
            bool d_only_whole_words
            bool d_case_insensitive

            config() except +

            bool is_allow_overlaps()
            void set_allow_overlaps(bool)
            bool is_only_whole_words()
            void set_only_whole_words(bool)
            bool is_case_insensitive()
            void set_case_insensitive(bool)

        basic_trie() except +

        basic_trie &remove_overlaps()
        basic_trie &case_insensitive()
        basic_trie &only_whole_words()

        void insert(string_type)
        void insert[InputIterator](InputIterator, InputIterator)
        emit_collection parse_text(string_type text)

ctypedef emit[char] c_emit
ctypedef vector[c_emit] c_emit_collection
ctypedef vector[c_emit].iterator c_emit_collection_iter
ctypedef basic_trie[char] wtrie

cdef class Trie:
    cdef wtrie Trie

    def __cinit__(self, case_insensitive=False, remove_overlaps=False, only_whole_words=False):
        if case_insensitive:
            self.Trie.case_insensitive()
        if remove_overlaps:
            self.Trie.remove_overlaps()
        if only_whole_words:
            self.Trie.only_whole_words()

    cpdef void insert(self, string word):
        self.Trie.insert(<string_type>word)
    
    cpdef int parse_text(self, string word):
        cdef int count = 0
        cdef c_emit_collection emits
        emits = self.Trie.parse_text(<string_type>word)
        count = emits.size()
        return count

    cpdef list parse_text_values(self, string word):
        cdef c_emit_collection emits
        cdef c_emit c_item
        emits = self.Trie.parse_text(<string_type>word)
        return [(c_item.get_keyword().c_str(), c_item.get_start()) for c_item in emits]