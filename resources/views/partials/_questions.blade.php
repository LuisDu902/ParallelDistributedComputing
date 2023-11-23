@if ($questions->count() > 0)
    <ul class="questions">
        @foreach($questions as $question)
            <li class="question-card">
                <div class="q-stats">
                    <span>{{ $question->votes }} votes</span>
                    <span>{{ $question->answers->count() }} answers</span>
                    <span>{{ $question->nr_views }} views</span>
                </div>
                <div class="q-content">
                    <a href="{{ route('question', ['id' => $question->id]) }}">
                        <h2>{{ $question->title }}</h2>
                    </a>

                    @if (strlen($question->latest_content()) >= 300)
                        <p>{{ substr($question->latest_content(), 0, 300) }}...</p>
                    @else
                        <p>{{ $question->latest_content() }}</p>
                    @endif
                    <span><a href="{{ route('profile', ['id' => $question->creator->id ]) }}" class="purple">{{ $question->creator->username }}</a> asked {{ $question->timeDifference() }} ago</span>
                </div>
            </li>
        @endforeach
    </ul>
    {{ $questions->links() }}
@else
    <div class="no-questions">
        <img class="no-questions-image" src="{{ asset('images/pikachuConfused.png') }}" alt="Psyduck Image">
        <p>No questions yet.</p>
    </div>
@endif