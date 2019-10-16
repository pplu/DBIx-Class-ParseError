package Op::Create;

use strict;
use warnings;
use Test::Roo::Role;
use Try::Tiny;

with 'Storage::Setup';

has _bar => ( is => 'rw' );

test 'rs->create' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    ok($self->_bar( $schema->resultset('Bar')->create({}) ), 'created Bar');
    ok( $schema->resultset('Foo')->create({
        name => 'Foo',
        is_foo => 1,
        bar => $self->_bar,
    }), 'created Foo' );
};

my $time = time();

test 'primary key' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    try {
        my $foo = $schema->resultset('Foo')->new({
            id => 1,
            name => 'Foo' . $time++,
            is_foo => 1,
            bar => $self->_bar,
        });
        $foo->insert;
    } catch {
        my $error = $_;
        ok($error, 'Failed to create with duplicated PK');
    };
};

test 'foreign key' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    try {
        $schema->resultset('Foo')->create({
            name => 'Foo' . $time++,
            is_foo => 1,
            bar_id => 1000
        });
    } catch {
        my $error = $_;
        ok($error, 'Failed to create with invalid FK');
    };
};

test 'unique key' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    try {
        $schema->resultset('Foo')->create({
            name => 'Foo',
            is_foo => 1,
            bar => $self->_bar,
        })
    } catch {
        my $error = $_;
        ok($error, 'Failed to create with duplicated name');
    };
};

test 'not null' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    try {
        $schema->resultset('Foo')->create({
            name => undef,
            is_foo => 1,
            bar => $self->_bar,
        })
    } catch {
        my $error = $_;
        ok($error, 'Failed to create with NULL on not null');
    };
};

test 'data type' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    try {
        $schema->resultset('Foo')->create({
            name => 'Foo' . $time++,
            is_foo => 'text value',
            bar => $self->_bar,
        })
    } catch {
        my $error = $_;
        ok($error, 'Failed to create with invalid data type');
    };
};

test 'missing column' => sub {
    my $self = shift;
    ok(my $schema = $self->schema, 'got schema');
    try {
        $schema->resultset('Foo')->create({
            name => 'Foo' . $time++,
            is_foo => 1,
            baz => 1000
        })
    } catch {
        my $error = $_;
        ok($error, 'Failed to create with missing column');
    };
};

1;
