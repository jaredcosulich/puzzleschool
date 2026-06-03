export default function YouTube({ id }: { id: string }) {
  return (
    <div className="embed-responsive embed-responsive-16by9">
      <iframe
        className="embed-responsive-item"
        allowFullScreen
        src={`https://www.youtube.com/embed/${id}`}
        title="YouTube video"
      />
    </div>
  );
}
